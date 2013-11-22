# encoding: utf-8
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  embeds_one :address
  attr_accessor :address_id

  embeds_many :order_items
  embeds_many :order_histories

  embeds_many :coupons

  STATES = {:pending => '等待付款',
            :paid => '已付款，等待确认',
            :confirmed => '已付款',
            :shipped => '已发货',
            :canceled => '订单取消',
            :closed => '订单关闭',
            :refunded => '已协商退款'}
  DELIVER_METHODS = {
      :sf => {name: '顺丰', price: 18.0},
      :zt => {name: '中通', price: 8.0}
  }
  PAYMENT_METHOD = {
      :tenpay => '财付通',
      :alipay => '支付宝'
  }

  field :state, type: Symbol, default: :pending
  field :payment_method, type: Symbol
  field :order_no, type: String
  field :deliver_by, type: Symbol
  field :deliver_no, type: String
  field :note, type: String
  field :admin_note, type: String
  field :system_note, type: String
  field :trade_no, type: String
  field :trade_price, type: BigDecimal
  field :trade_state, type: String
  field :deliver_price, type: BigDecimal#, default: DELIVER_METHODS.first[1][:price]

  validates :state, presence: true, inclusion: {in: STATES.keys}
  validates :deliver_by, presence: true, inclusion: {in: DELIVER_METHODS.keys}
  validates :payment_method, inclusion: {in: PAYMENT_METHOD.keys, allow_blank: true}
  validates_associated :address
  validates :user, presence: true
  attr_accessible :note, :deliver_by, :address_id
  attr_accessible :state, :admin_note, :deliver_no, :trade_no, :coupons_attributes,
                  :as => :admin

  accepts_nested_attributes_for :coupons, allow_destroy: true, reject_if: :all_blank

  before_create do
    self.order_no = rand.to_s[2..11]
    self.deliver_price = calculate_deliver_price
    # mongoid may not rollback when error occurred
    order_items.each &:claim_stock!
  end

  validate do
    errors.add :price, "总价必须大于1元" if total_price < 1
  end

  validate do
    errors.add :address_id, "必须选择收货地址" unless self.address
  end

  after_create do
    user.cart_items.destroy_all(:thing.in => order_items.map(&:thing), :kind_id.in => order_items.map(&:kind).map(&:id))
  end

  default_scope -> { order_by(:created_at => :desc) }

  def state
    super.to_sym
  end

  STATES.keys.each do |s|
    scope s, -> { where state: s }
    define_method :"#{s}?" do
      state == s
    end
  end

  def can_pay?
    pending?
  end

  def can_confirm_payment?
    # There is a situation is user closed or canceled order, but still paid at third party
    # IMPORTANT: stock
    paid? || pending? || canceled? || closed?
  end

  def can_ship?
    confirmed?
  end

  def can_cancel?
    pending?
  end

  def can_close?
    pending?
  end

  def can_refund?
    confirmed? || shipped?
  end

  def pay!(trade_no, price, method, raw)
    return false unless can_pay?

    self.state = :paid
    self.payment_method = method
    self.trade_no = trade_no
    self.trade_price = price
    save!

    order_histories.create from: :pending, to: :paid, raw: raw
  end

  def confirm_payment!(trade_no, price, method, raw)
    return false unless can_confirm_payment?

    state = self.state
    if canceled? || closed?
      self.system_note += '*用户取消了订单或订单已关闭，但仍然进行了支付，注意库存！'
    end
    self.state = :confirmed
    self.payment_method = method
    self.trade_no = trade_no
    self.trade_price = price
    save!

    order_histories.create from: state, to: :confirmed, raw: raw
  end

  def ship!(deliver_no, admin_note = '')
    return false unless can_ship?

    self.state = :shipped
    self.deliver_no = deliver_no
    self.admin_note = admin_note if admin_note.present?
    save!

    order_histories.create from: :confirmed, to: :shipped
  end

  def cancel!(raw = {})
    return false unless can_cancel?

    order_items.each &:revert_stock!
    self.state = :canceled
    save!

    order_histories.create from: :pending, to: :canceled, raw: raw
  end

  def close!
    return false unless can_close?

    order_items.each &:revert_stock!
    self.state = :closed
    save!

    order_histories.create from: :pending, to: :closed
  end

  def refund!
    return false unless can_refund?

    state = self.state
    self.state = :refunded
    save!

    order_histories.create from: state, to: :closed
  end

  def all_products_have_stock?
    order_items.map { |item| item.kind.stock >= item.quantity }.reduce &:&
  end

  def has_stock?
    order_items.select {|item| item.kind.stage == :stock}.any?
  end

  def calculate_deliver_price
    Order.calculate_deliver_price_by_method_and_price(self.deliver_by, items_price)
  end

  def items_price
    order_items.map(&:price).reduce(&:+) || 0
  end

  def coupons_price
    coupons.map(&:price).reduce(&:+) || 0
  end

  def total_price
    items_price + (self.deliver_price || calculate_deliver_price) + coupons_price
  end

  def total_cents
    (total_price * 100).to_i
  end

  class<< self
    def build_order(user, params = {})
      address_id = params.delete :address_id
      order = user.orders.build params
      order.address = user.addresses.find(address_id) if address_id
      user.cart_items.each { |item| OrderItem.build_by_cart_item(order, item)}
      order
    end

    def calculate_deliver_price_by_method_and_price(method, items_price)
      price = case items_price
                when 0..500
                  DELIVER_METHODS[method][:price]
                when 500..1000
                  DELIVER_METHODS[method][:price] - 10
                else
                  DELIVER_METHODS[method][:price] - 20
              end
      price > 0 ? price : 0
    end

    def cleanup_expired_orders
      pending.where(:created_at.lt => 1.days.ago).each(&:close!)
    end
  end
end
