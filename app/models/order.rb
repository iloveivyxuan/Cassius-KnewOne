# encoding: utf-8
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  attr_accessor :address
  field :district, type: String
  field :location, type: String
  field :contact_name, type: String
  field :phone, type: String
  field :zip_code, type: String
  validates :district, :location, :contact_name, :phone, presence: true

  embeds_many :order_items
  has_many :order_histories

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

  field :state, type: Symbol, default: :pending
  field :paid_at, type: Time
  field :confirmed_at, type: DateTime
  field :shipped_at, type: DateTime
  field :canceled_at, type: DateTime
  field :closed_at, type: DateTime
  field :refunded_at, type: DateTime

  field :deliver_by, type: Symbol, default: :sf
  field :deliver_no, type: String
  field :note, type: String
  field :admin_note, type: String
  field :trade_no, type: String
  field :deliver_price, type: BigDecimal#, default: DELIVER_METHODS.first[1][:price]

  validates :state, presence: true, inclusion: {in: STATES.keys}
  validates :deliver_by, presence: true, inclusion: {in: DELIVER_METHODS.keys}
  validates :user, presence: true
  attr_accessible :note, :deliver_by
  attr_accessible :state, :admin_note, :deliver_no, :trade_no,
                  :paid_at, :confirmed_at, :shipped_at, :canceled_at, :closed_at, :refunded_at,
                  :as => :admin

  before_create do
    self.deliver_price = calculate_deliver_price
  end

  after_create do
    user.cart_items.destroy_all(:kind.in => order_items.map(&:thing_kind))
    order_items.each &:claim_stock!
  end

  scope :pending, -> { where state: :pending }
  scope :paid, -> { where state: :paid }
  scope :confirmed, -> { where state: :confirmed }
  scope :shipped, -> { where state: :shipped }
  scope :canceled, -> { where state: :canceled }
  scope :closed, -> { where state: :closed }
  scope :refunded, -> { where state: :refunded }

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

  def closed?
    self.state == :closed
  end

  def refunded?
    self.state == :refunded
  end

  def can_pay?
    pending?
  end

  def can_confirm_payment?
    paid?
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

  def pay!(trade_no)
    return false unless can_pay?

    self.state = :paid
    self.paid_at = Time.now
    self.trade_no = trade_no
    save!

    order_histories.create from: :pending, to: :paid
  end

  def confirm_payment!(trade_no)
    return false unless can_confirm_payment? && self.trade_no == trade_no

    self.state = :confirmed
    self.confirmed_at = Time.now
    save!

    order_histories.create from: :paid, to: :confirmed
  end

  def ship!
    return false unless can_ship?

    self.state = :shipped
    self.shipped_at = Time.now
    save!

    order_histories.create from: :confirmed, to: :shipped
  end

  def cancel!
    return false unless can_cancel?

    order_items.each &:revert_stock!
    self.state = :canceled
    self.canceled_at = Time.now
    save!

    order_histories.create from: :pending, to: :canceled
  end

  def close!
    return false unless can_close?

    order_items.each &:revert_stock!
    self.state = :closed
    self.closed_at = Time.now
    save!

    order_histories.create from: :pending, to: :closed
  end

  def refund!
    return false unless can_refund?

    state = self.state
    self.state = :refunded
    self.refunded_at = Time.now
    save!

    order_histories.create from: state, to: :closed
  end

  def all_products_have_stock?
    order_items.map { |item| item.thing_kind.stock >= item.quantity }.reduce &:&
  end

  def set_address(address)
    self.district = address.district.area_name ' '
    self.location = address.address
    self.contact_name = address.name
    self.phone = address.phone
    self.zip_code = address.zip_code
  end

  def address_text
    "#{contact_name}, #{phone}, #{district} #{location} #{", #{zip_code}" if zip_code.present?}"
  end

  def deliver_method_text
    DELIVER_METHODS[self.deliver_by][:name]
  end

  def state_text
    STATES[self.state]
  end

  def calculate_deliver_price
    Order.calculate_deliver_price_by_method_and_price(self.deliver_by, items_price)
  end

  def items_price
    order_items.map(&:price).reduce(&:+) || 0
  end

  def total_price
    items_price + (self.deliver_price || calculate_deliver_price)
  end

  class<< self
    def place_order(user, params = {})
      address = if params[:address]
                  user.addresses.find(params.delete(:address))
                elsif user.addresses.any?
                  user.addresses.first
                end
      order = user.orders.build params
      order.set_address address if address
      user.cart_items.each { |item| OrderItem.build_by_cart_item(order, item) if item.has_stock? }
      order
    end

    def calculate_deliver_price_by_method_and_price(method, items_price)
      price = case items_price
                when 1..500
                  DELIVER_METHODS[method][:price]
                when 500..1000
                  DELIVER_METHODS[method][:price] - 10
                else
                  DELIVER_METHODS[method][:price] - 20
              end
      price > 0 ? price : 0
    end
  end
end
