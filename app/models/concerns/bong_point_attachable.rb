module BongPointAttachable
  extend ActiveSupport::Concern

  BONG_POINT_VALUE = 1

  included do
    field :minimal_consumable_bong_point, type: Integer, default: 0
    field :maximal_consumable_bong_point, type: Integer, default: 0

    field :consumed_bong_point, type: Integer, default: 0
    field :refunded_bong_point, type: Integer, default: 0

    has_many :bong_point_transactions

    scope :bong_point_consumed, -> { where :consumed_bong_point.gt => 0 }

    def bong_point=(val)
      @bong_point = val.to_i
    rescue
      @bong_point = 0
    end

    def bong_point
      @bong_point || 0
    end
  end

  def bong_point_required?
    self.minimal_consumable_bong_point > 0
  end

  def bong_point_consumed?
    self.consumed_bong_point > 0
  end

  def can_consume_bong_point?
    pending? &&
      self.coupon_code.nil? &&
      self.user.bong_bind? &&
      self.maximal_consumable_bong_point > 0 &&
      !bong_point_consumed?
  end

  def consume_bong_point!(point)
    return false unless can_consume_bong_point?

    if point > self.maximal_consumable_bong_point ||
      point < self.minimal_consumable_bong_point ||
      point == 0
      return false
    end

    r = self.user.bong_client.consume_bong_point_by_order(self, point)

    return false unless r

    self.bong_point_transactions.create! r.merge(type: :consuming)

    if r[:success]
      self.consumed_bong_point = r[:bong_point]
      self.rebates.build name: 'bong活跃点兑换',
                         note: "消费 #{self.consumed_bong_point} bong活跃点",
                         price: -self.consumed_bong_point * BONG_POINT_VALUE
      sync_price

      if total_price == 0
        self.state = :freed
      end
    end

    save!

    confirm_free!

    r[:success]
  end

  def can_refund_bong_point?
    self.consumed_bong_point > 0 &&
      self.refunded_bong_point < self.consumed_bong_point
  end

  def refund_bong_point!(point, operator)
    return false unless can_refund_bong_point? || operator.present?

    if point == 0 ||
      self.refunded_bong_point + point > self.consumed_bong_point
      return false
    end

    if r = self.user.bong_client.refund_bong_point_by_order(self, point, operator)
      self.bong_point_transactions.create! r.merge(type: :refunding)

      if r[:success]
        self.refunded_bong_point += point
        true
      else
        false
      end
    else
      log :system, '退活跃点时与bong通讯异常'
      save!
      false
    end
  end

  def cal_and_set_consumable_bong_point
    self.minimal_consumable_bong_point = 0
    self.maximal_consumable_bong_point = 0

    self.order_items.includes(:thing).each do |item|
      k = item.kind

      if k.can_consume_bong_point?
        self.minimal_consumable_bong_point += k.minimal_bong_point * item.quantity
        self.maximal_consumable_bong_point += k.maximal_bong_point * item.quantity
      end
    end
  end
end
