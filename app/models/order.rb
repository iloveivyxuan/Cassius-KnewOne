# encoding: utf-8
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :address
  embeds_many :order_items

  field :trade_no, type: String
  field :state, type: String, default: :pending

  STATES = {:pending => '等待付款',
           :paid => '已付款，等待确认',
           :confirmed => '已付款',
           :shipped => '已发货',
           :canceled => '订单取消'}
  validates :state, presence: true, inclusion: { in: STATES.keys }

  def state
    super.to_sym
  end

  def pending?
    self.state == :pending
  end

  def paid?
    self.state == :paid
  end

  def confirmed?
    self.state == :confirmed
  end

  def shipped?
    self.state == :shipped
  end

  def canceled?
    self.state == :canceled
  end

  def can_pay?
    pending? && all_products_have_stock?
  end

  def can_confirm_payment?
    paid?
  end

  def can_shipped?
    confirmed?
  end

  def can_canceled?
    pending?
  end

  def pay!(trade_no)
    return false unless can_pay?

    order_items.each &:claim_stock
    update_attributes trade_no: trade_no, state: :paid
  end

  def confirm_payment!(trade_no)
    return false unless can_confirm_payment? && self.trade_no == trade_no

    update_attributes state: :confirmed
  end

  def ship!
    return false unless can_shipped?

    update_attributes state: :shipped
  end

  def cancel!
    return false unless can_canceled?

    order_items.each &:revert_stock
    update_attributes state: :canceled
  end

  private

  def all_products_have_stock?
    order_items.map {|item| item.thing_kind.stock >= item.quantity}.reduce &:&
  end
end
