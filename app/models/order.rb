# encoding: utf-8
class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  embeds_one :address
  attr_accessor :address_id
  alias_method :_address=, :address=
  def address=(val)
    return nil unless val

    self.address_id = val.id.to_s
    self._address = val
  end

  embeds_one :invoice
  attr_accessor :invoice_id
  alias_method :_invoice=, :invoice=
  def invoice=(val)
    return nil unless val

    self.invoice_id = val.id.to_s
    self._invoice = val
  end

  embeds_many :order_items
  embeds_many :order_histories

  embeds_many :rebates

  has_one :coupon_code, autosave: true
  attr_accessor :coupon_code_id

  def coupon_code_id=(id)
    self.coupon_code = CouponCode.where(id: id).first
    @coupon_code_id = self.coupon_code.nil? ? '' : id
  end

  STATES = {:pending => '等待付款',
            :freed => '无需支付，等待用户确认',
            :confirmed => '支付成功，等待客服受理',
            :shipped => '已发货',
            :canceled => '订单取消',
            :closed => '订单关闭',
            :refunded => '已协商退款'}
  DELIVER_METHODS = {
      :sf => '顺丰',
      :zt => '中通'
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
  field :alteration, type: String
  field :trade_no, type: String
  field :trade_price, type: BigDecimal
  field :trade_state, type: String
  field :deliver_price, type: BigDecimal
  field :auto_owning, type: Boolean, default: true
  field :price, type: BigDecimal

  mount_uploader :waybill, WaybillUploader

  validates_numericality_of :price, :greater_than_or_equal_to => 0, :unless => Proc.new { |order| !order.persisted? }
  validates :state, presence: true, inclusion: {in: STATES.keys}
  validates :deliver_by, presence: true, inclusion: {in: DELIVER_METHODS.keys}
  validates :payment_method, inclusion: {in: PAYMENT_METHOD.keys, allow_blank: true}
  validates_associated :address
  validates :user, presence: true

  accepts_nested_attributes_for :rebates, allow_destroy: true, reject_if: :all_blank

  after_build do
    self.address = self.user.addresses.where(id: self.address_id).first if self.address_id
    self.invoice = self.user.invoices.where(id: self.invoice_id).first if self.invoice_id
    self.coupon_code = CouponCode.where(id: self.coupon_code_id).first if self.coupon_code_id

    unless self.coupon_code.nil?
      if self.coupon_code.bound_user?
        self.coupon_code.use
      else
        self.coupon_code.bind_order_user_and_use
      end
    end
  end

  before_create do
    self.order_no = rand.to_s[2..11]
    self.deliver_price = calculate_deliver_price
    # mongoid may not rollback when error occurred
    order_items.each &:claim_stock!
    sync_price
  end

  before_create do
    self.state = :freed if free?
  end

  validate do
    errors.add :price, "总价必须大于等于0元" if total_price < 0
  end

  validate do
    errors.add :address_id, "必须选择收货地址" unless self.address
  end

  validate on: :create do
    unless self.coupon_code.nil?
      errors.add :coupon_code, '不能使用这个优惠券' unless self.coupon_code.usable?
    end
  end

  after_create do
    user.cart_items.destroy_all(:thing.in => order_items.map(&:thing), :kind_id.in => order_items.map(&:kind).map(&:id))
  end

  after_save do
    generate_waybill! if confirmed?
  end

  default_scope order_by(created_at: :desc)

  def state
    super.to_sym
  end

  def sync_price
    self.price = calculate_price
  end

  def free?
    total_price == 0
  end

  STATES.keys.each do |s|
    scope s, -> { where state: s }
    define_method :"#{s}?" do
      state == s
    end
  end

  # There is a situation is user closed or canceled order, but still paid at third party
  # IMPORTANT: stock
  def can_confirm_payment?
    pending? || canceled? || closed?
  end

  def can_pay?
    pending?
  end

  def can_confirm_free?
    freed?
  end

  def can_ship?
    confirmed?
  end

  def can_cancel?
    pending? || freed?
  end

  def can_close?
    pending?
  end

  def can_refund?
    confirmed? || shipped?
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

  def confirm_free!
    return false unless can_confirm_free?

    self.state = :confirmed
    save!

    order_histories.create from: :freed, to: :confirmed
  end

  def ship!(deliver_no, admin_note = '')
    return false unless can_ship?

    self.state = :shipped
    self.deliver_no = deliver_no

    if admin_note.present?
      if self.admin_note.present?
        admin_note = " | #{admin_note}"
      else
        self.admin_note = ''
      end

      self.admin_note += admin_note
    end

    save!

    own_things if auto_owning?

    order_histories.create from: :confirmed, to: :shipped
  end

  def cancel!(raw = {})
    return false unless can_cancel?

    self.coupon_code.undo unless self.coupon_code.nil?

    order_items.each &:revert_stock!
    self.state = :canceled
    save!

    order_histories.create from: :pending, to: :canceled, raw: raw
  end

  def close!
    return false unless can_close?

    self.coupon_code.undo unless self.coupon_code.nil?

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

    # unown_things if auto_owning?

    order_histories.create from: state, to: :closed
  end

  def all_products_have_stock?
    order_items.map { |item| item.kind.stock >= item.quantity }.reduce &:&
  end

  def has_stock?
    order_items.select { |item| item.kind.stage == :stock }.any?
  end

  def calculate_deliver_price
    return 0 if self.deliver_by.nil? || self.address.nil?
    price = Province[self.address.province][self.deliver_by.to_s]
    case items_price
      when 0..499
      when 500..1000
        price -= 10
      else
        price -= 20
    end

    price > 0 ? price : 0
  end

  def items_price
    order_items.map(&:price).reduce(&:+) || 0
  end

  def rebates_price
    rebates.map(&:price).reduce(&:+) || 0
  end

  def receivable
    items_price + (persisted? ? self.deliver_price : calculate_deliver_price)
  end

  def calculate_price
    price = receivable + rebates_price
    price >= 0 ? price : 0
  end

  def total_price
    persisted? ? self.price : calculate_price
  end

  def total_cents
    (total_price * 100).to_i
  end

  def generate_waybill!
    return unless waybill.url.nil?
    WayBillWorker.perform_async(self.id.to_s)
  end

  def own_things
    order_items.each do |item|
      item.thing.own self.user
    end
  end

  def unown_things
    order_items.each do |item|
      item.thing.unown self.user
    end
  end

  def add_item_by_cart_item(cart_item)
    return false unless cart_item.legal? && cart_item.has_enough_stock?

    self.order_items.build({
                               thing_title: cart_item.thing.title,
                               kind_title: cart_item.kind.title,
                               quantity: cart_item.quantity,
                               thing: cart_item.thing.id,
                               kind_id: cart_item.kind.id,
                               single_price: cart_item.kind.price
                           })

    true
  end

  def add_items_from_cart(cart_items)
    cart_items.map { |item| add_item_by_cart_item item }.reduce &:|
  end

  class<< self
    def build_order(user, params = {})
      params ||= {}
      order = user.orders.build params
      order.add_items_from_cart user.cart_items

      order
    end

    def calculate_deliver_price_by_method_and_price(method, province, items_price)
      price = Province[province][method.to_s]
      case items_price
        when 0..499
        when 500..1000
          price -= 10
        else
          price -= 20
      end

      price > 0 ? price : 0
    end

    def cleanup_expired_orders
      pending.where(:created_at.lt => 1.days.ago).each(&:close!)
    end
  end
end
