# encoding: utf-8
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :address
  embeds_many :order_items
  has_many :order_histories

  field :trade_no, type: String
  field :state, type: Symbol, default: :pending
  field :deliver_by, type: Symbol, default: :sf
  field :note, type: String
  field :total_price, type: BigDecimal

  STATES = {:pending => '等待付款',
            :paid => '已付款，等待确认',
            :confirmed => '已付款',
            :shipped => '已发货',
            :canceled => '订单取消'}
  DELIVER_METHOD = {
      :sf => {name: '顺丰', price: 18},
      :zt => {name: '中通', price: 8}
  }
  validates :state, presence: true, inclusion: {in: STATES.keys}
  validates :delivery_by, presence: true, inclusion: {in: DELIVER_METHOD.keys}
  validates :address, :user, presence: true
  attr_protected :state, :trade_no

  before_create do
    self.total_price = order_items.map(&:price).reduce(&:+) + DELIVER_METHOD[self.deliver_by][:price]
  end

  after_create do
    user.cart_items.destroy_all(:kind.in => order_items.map(&:thing_kind))
    order_items.each &:claim_stock!
  end

  def state
    super.to_sym
  end

  def humanize_state
    STATES[self.state]
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
    pending?
  end

  def can_confirm_payment?
    paid?
  end

  def can_shipped?
    confirmed?
  end

  def can_cancel?
    pending?
  end

  def pay!(trade_no)
    return false unless can_pay?

    self.state = :paid
    self.trade_no = trade_no
    save!

    order_histories.create from: :pending, to: :paid
  end

  def confirm_payment!(trade_no)
    return false unless can_confirm_payment? && self.trade_no == trade_no

    update_attributes! state: :confirmed
    self.state = :confirmed
    save!

    order_histories.create from: :paid, to: :confirmed
  end

  def ship!
    return false unless can_shipped?

    self.state = :shipped!
    save!

    order_histories.create from: :confirmed, to: :shipped
  end

  def cancel!
    return false unless can_cancel?

    order_items.each &:revert_stock!
    self.state = :canceled
    save!

    order_histories.create from: :pending, to: :canceled
  end

  def all_products_have_stock?
    order_items.map { |item| item.thing_kind.stock >= item.quantity }.reduce &:&
  end

  class<< self
    def place_order(user, params = {})
      order = user.orders.build params
      user.cart_items.each { |item| OrderItem.build_by_cart_item(order, item) }
      order
    end
  end
end
