module BongPointAttachable
  extend ActiveSupport::Concern

  included do
    field :minimal_consumable_bong_point, type: Integer, default: 0
    field :maximal_consumable_bong_point, type: Integer, default: 0

    field :consumed_bong_point, type: Integer, default: 0

    has_many :bong_point_transaction

    attr_accessor :auto_consume_bong_point

    after_build do
      cal_and_set_consumable_bong_point!
    end
  end

  private

  def cal_and_set_consumable_bong_point!
    self.minimal_consumable_bong_point = 0
    self.maximal_consumable_bong_point = 0

    self.order_items.includes(:thing).map(&:kind).each do |k|
      if k.can_consume_bong_point?
        self.minimal_consumable_bong_point += k.minimal_bong_point
        self.maximal_consumable_bong_point += k.maximal_bong_point
      end
    end
  end
end
