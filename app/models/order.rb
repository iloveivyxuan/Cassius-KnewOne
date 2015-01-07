class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  include BongPointAttachable
  include Aftermath

  belongs_to :user

  index created_at: 1

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

  scope :by_thing_kind, ->(kind) { where 'order_items.thing_id' => kind.thing.id, 'order_items.kind_id' => kind.id.to_s }
  scope :by_thing, ->(thing) { where 'order_items.thing_id' => thing.id }
  scope :without_thing, ->(thing) { ne 'order_items.thing_id' => thing.id }

  scope :since_date, ->(date) { where :created_at.gte => date.to_time.to_i }
  scope :until_date, ->(date) { where :created_at.lt => date.next_day.to_time.to_i }

  embeds_many :rebates

  has_one :coupon_code, autosave: true
  attr_accessor :coupon_code_id

  def coupon_code_id=(id)
    self.coupon_code = CouponCode.where(id: id).first
    @coupon_code_id = self.coupon_code.nil? ? '' : id
  end

  attr_accessor :use_sf
  attr_accessor :bong_delivery

  def use_sf?
    !['0', false, 'false', nil].include?(self.use_sf) || self.deliver_by == :sf
  end

  def bong_delivery
    self.deliver_by == :bong_delivery
  end

  SF_PRICE = 10.0
  STATES = {
    :pending => '等待付款',
    :freed => '无需支付，请用户确认',
    :confirmed => '支付成功，等待发货',
    :transit => '正在安排出库',
    :shipped => '已发货',
    :canceled => '订单取消',
    :closed => '订单关闭',
    :request_refund => '退款等待受理',
    :refunded => '已协商退款',
    :refunded_to_balance => '已退款到余额',
    :refunded_to_platform => '已退款到第三方支付平台',
    :unexpected => '订单异常，请联系客服'
  }
  DELIVER_METHODS = {
    # Legacy code
    :sf => '顺丰',
    :zt => '中通',
    :bong_delivery => 'bong',
    :other => '其他',
    # same as https://code.google.com/p/kuaidi-api/wiki/Open_API_API_URL
    :yuantong => '圆通速递',
    :debangwuliu => '德邦物流',
    :huitongkuaidi => '百世汇通',
    :shunfeng => '顺丰速递',
    :zhongtong => '中通速递',
    :ems => 'EMS',
    :shentong => '申通速递',
    :youshuwuliu => '优速物流',
    :yunda => '韵达快运',
    :tiantian => '天天速递'
  }
  PAYMENT_METHOD = {
    :tenpay => '财付通',
    :alipay => '支付宝',
    :alipay_wap => '支付宝移动支付',
    :wxpay => '微信支付',
    :btc => '比特币',
    :other => '其它'
  }

  field :state, type: Symbol, default: :pending
  field :payment_method, type: Symbol
  field :order_no, type: String
  field :deliver_by, type: Symbol
  field :deliver_no, type: String
  field :buy_as_gift, type: Boolean, default: false
  field :note, type: String
  field :refund_note, type: String
  field :admin_note, type: String, default: ''
  field :system_note, type: String, default: ''
  field :alteration, type: String
  field :trade_no, type: String
  field :trade_price, type: BigDecimal
  field :trade_state, type: String
  field :deliver_price, type: BigDecimal
  field :auto_owning, type: Boolean, default: true
  field :use_balance, type: Boolean, default: false
  field :expense_balance, type: BigDecimal, default: 0
  field :price, type: BigDecimal
  field :pre_order, type: Boolean, default: false
  field :valid_period_days, type: Integer, default: 1
  field :pay_at, type: DateTime, default: nil

  mount_uploader :waybill, WaybillUploader

  validates_numericality_of :price, :greater_than_or_equal_to => 0, :unless => Proc.new { |order| !order.persisted? }
  validates :state, presence: true, inclusion: {in: STATES.keys}
  validates :deliver_by, presence: true, inclusion: {in: DELIVER_METHODS.keys}
  validates :payment_method, inclusion: {in: PAYMENT_METHOD.keys, allow_blank: true}
  validates_associated :address
  validates :user, presence: true

  accepts_nested_attributes_for :rebates, allow_destroy: true, reject_if: :all_blank

  scope :deal, -> { unscoped.in(state: [:confirmed, :shipped, :freed]).desc(:created_at) }

  after_build do
    if self.address_id.present? && address = self.user.addresses.unscoped.where(id: self.address_id).first
      self.address = address
    else
      build_address
    end

    self.invoice = self.user.invoices.where(id: self.invoice_id).first if self.invoice_id
    @bong_point ||= 0
  end

  before_create do
    self.order_no = rand.to_s[2..11]
    # in case of order_no start with 0,
    # which will be inconvenient in Excel
    self.order_no[0] = "1" if self.order_no.start_with?("0")
    self.deliver_price = calculate_deliver_price
    self.pre_order = order_items.all? {|i| i.kind.stage == :pre_order}

    # mongoid may not rollback when error occurred
    order_items.each &:claim_stock!
    sync_price
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

    if self.address.upgrade_required?
      errors.add :address, '地址需要更新'
    end
  end

  after_create do
    self.user.cart_items.where(:thing.in => order_items.map(&:thing), :kind_id.in => order_items.map(&:kind).map(&:id)).destroy_all

    consume_bong_point!(self.bong_point) if self.bong_point > 0

    free!
    confirm_free!

    OrderMailer.delay_for(3.hours, retry: false, queue: :mails).remind_payment(self.id.to_s)
  end

  after_save do
    generate_waybill! if confirmed?
  end

  default_scope -> { order_by(created_at: :desc) }

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

  def can_free?
    pending?
  end

  # There is a situation is user closed or canceled order, but still paid at third party
  # IMPORTANT: stock
  def can_confirm_payment?
    pending? || canceled? || closed?
  end

  def can_pay?
    pending? && (!bong_point_required? || bong_point_required? && bong_point_consumed?)
  end

  def can_confirm_free?
    (freed? || self.expense_balance == total_price) && freed?
  end

  def can_ship?
    transit? || confirmed?
  end

  def can_transit?
    confirmed?
  end

  def can_cancel?
    pending? || freed?
  end

  def can_close?
    pending?
  end

  def can_request_refund?
    confirmed?
  end

  def can_cancel_request_refund?
    request_refund?
  end

  def can_refund?
    request_refund? || confirmed? || shipped?
  end

  def can_refunded_balance_to_platform?
    refunded_to_balance?
  end

  def free!
    return false unless can_free?

    state = self.state

    if free?
      self.state = :freed
    elsif use_balance? && self.user.has_balance?
      available_balance = self.user.balance

      if available_balance - total_price >= 0 && self.user.expense_balance!(total_price, "支付订单#{self.order_no}")
        self.expense_balance = total_price
        self.state = :freed
      elsif self.user.expense_balance!(available_balance, "支付订单#{self.order_no}")
        self.expense_balance = available_balance
      else
        self.state = :unexpected
      end
    end

    save!

    order_histories.create from: state, to: self.state
  end

  def confirm_payment!(trade_no, price, method, raw)
    order_histories.create! from: self.state, raw: raw

    return false unless can_confirm_payment?

    state = self.state

    if canceled? || closed?
      if self.admin_note.blank?
        self.system_note = ''
      else
        self.system_note += ' | '
      end

      self.system_note += '*用户取消了订单或订单已关闭，但仍然进行了支付，注意库存！'
    end

    self.state = :confirmed
    self.pay_at ||= Time.now
    self.payment_method = method
    self.trade_no = trade_no
    self.trade_price = price
    save!

    order_histories.create from: state, to: :confirmed, raw: raw

    after_confirm

    true
  end

  def confirm_free!
    return false unless can_confirm_free?

    self.state = :confirmed
    self.pay_at ||= Time.now
    save!

    order_histories.create from: :freed, to: :confirmed

    after_confirm

    true
  end

  def ship!(deliver_no, admin_note = '', deliver_by = self.deliver_by)
    return false unless can_ship?

    self.state = :shipped
    self.deliver_no = deliver_no
    self.deliver_by = deliver_by

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

    OrderMailer.delay(retry: false, queue: :mails).ship(self.id.to_s)
  end

  def transit!
    return false unless can_transit?

    self.state = :transit

    save!

    order_histories.create from: :confirmed, to: :transit
  end

  def cancel!(raw = {})
    return false unless can_cancel?

    self.coupon_code.undo unless self.coupon_code.nil?

    order_items.each &:revert_stock!
    self.state = :canceled
    save!

    if self.expense_balance > 0
      self.user.recharge_balance!(self.expense_balance, "订单#{self.order_no}因取消的退款")
      self.expense_balance = 0
      save!
    end

    if self.consumed_bong_point > 0 && self.refunded_bong_point == 0
      refund_bong_point! self.consumed_bong_point, 'SYSTEM(ON CANCELING)'
    end

    order_histories.create from: :pending, to: :canceled, raw: raw
  end

  def close!
    return false unless can_close?

    self.coupon_code.undo unless self.coupon_code.nil?

    order_items.each &:revert_stock!
    self.state = :closed
    save!

    if self.expense_balance > 0
      self.user.recharge_balance!(self.expense_balance, "订单#{self.order_no}因关闭的退款")

      self.expense_balance = 0
      save!
    end

    if self.consumed_bong_point > 0 && self.refunded_bong_point == 0
      refund_bong_point! self.consumed_bong_point, 'SYSTEM(ON CLOSING)'
    end

    order_histories.create from: :pending, to: :closed
  end

  def force_close!(revert_stock = true)
    state = self.state

    self.coupon_code.undo unless self.coupon_code.nil?

    order_items.each &:revert_stock! if revert_stock
    self.state = :closed
    save!

    if self.expense_balance > 0
      self.user.recharge_balance!(self.expense_balance, "订单#{self.order_no}因关闭的退款")

      self.expense_balance = 0
      save!
    end

    order_histories.create from: state, to: :closed
  end

  def force_confirm_payment!(trade_no, price, method)
    state = self.state

    self.state = :confirmed
    self.payment_method = method
    self.trade_no = trade_no
    self.trade_price = price
    self.pay_at ||= Time.now
    save!

    order_histories.create from: state, to: :confirmed

    after_confirm

    true
  end

  def request_refund!(reason)
    return false unless can_request_refund?

    state = self.state
    self.state = :request_refund
    self.refund_note = reason

    save!

    order_histories.create from: state, to: :request_refund
  end

  def cancel_request_refund!
    return false unless can_cancel_request_refund?

    self.state = :confirmed

    save!

    order_histories.create from: :request_refund, to: :confirmed
  end

  def refund!
    return false unless can_refund?

    state = self.state
    self.state = :refunded_to_platform
    save!

    # unown_things if auto_owning?

    order_histories.create from: state, to: :refunded_to_platform
  end

  def refund_to_balance!(price = 0)
    return false unless can_refund? || price > total_price

    state = self.state
    self.state = :refunded_to_balance

    should_return_balance = (price == 0 ? (self.trade_price || 0) + self.expense_balance : price)
    self.user.refund_to_balance!(self, should_return_balance, "订单#{self.order_no}的退款")

    self.expense_balance = 0
    save!

    # unown_things if auto_owning?

    order_histories.create from: state, to: :refunded_to_balance
  end

  def refunded_balance_to_platform!
    return false unless can_refunded_balance_to_platform?

    refund_log = self.user.balance_logs.where(order_id: self.id, _type: 'RefundBalanceLog').first
    self.user.revoke_refund_to_balance! self, refund_log.value, "订单#{self.order_no}的退款改退支付平台"

    self.state = :refunded_to_platform
    save!

    order_histories.create from: :refunded_to_balance, to: :refunded_to_platform
  end

  def unexpect!(system_note = '', raw = {})
    order_histories.create from: self.state, raw: raw

    state = self.state
    self.state = :unexpected

    if system_note.present?
      if self.system_note.present?
        system_note = " | #{system_note}"
      else
        self.system_note = ''
      end

      self.system_note += system_note
    end

    save!

    order_histories.create from: state, to: :unexpected, raw: raw
  end

  def has_pre_order_items?
    order_items.any? {|i| i.kind.stage == :pre_order}
  end

  def all_products_have_stock?
    order_items.map { |item| item.kind.stock >= item.quantity }.reduce &:&
  end

  def has_stock?
    order_items.select { |item| item.kind.stage == :stock }.any?
  end

  def calculate_deliver_price
    price = items_price - (order_items.virtual.map(&:price).reduce(&:+) || 0)

    return 0 if price.zero? && order_items.virtual.size > 0

    case self.deliver_by
    when :zt, :zhongtong
      price < 88 ? 9 : 0
    when :sf, :shunfeng
      if price < 88
        19
      elsif price < 500
        10
      else
        0
      end
    else
      0
    end
  end

  def items_price
    order_items.map(&:price).reduce(&:+) || 0
  end

  def dyson_air # Dyson Air Multiplier
    Thing.find("510689ef7373c2f82b000003")
  end

  def rebates_price
    if rebates.blank? || not_dyson_coupon(rebates)
      rebates.map(&:price).reduce(&:+) || 0
    else
      amount = rebates.first.order.order_items.where(thing: dyson_air).map(&:quantity).reduce(&:+)
      amount * (rebates.map(&:price).reduce(&:+)) || 0
    end
  end

  def not_dyson_coupon(rebates)
    rebates.first.order.order_items.where(thing: dyson_air).blank?
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

  def should_pay_price
    total_price - self.expense_balance
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
                               virtual: cart_item.kind.virtual?,
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

  def delivered_at
    h = order_histories.select { |h| h.to == :shipped }.first

    h ? h.created_at : nil
  end

  def bong_inside?
    bong_family = %w(544f8b9331302d5139c60000 544f8b0a31302d4fd2dd0000 54700f5d31302d2b49260100 547eb49431302d676c830000 54868ff731302d10625a0300)
    bong_family.map { |bong| self.order_items.by_id(bong).exists? }.reduce(:|)
  end

  def pure_virtual?
    order_items.virtual.size == order_items.size
  end

  def set_coupon!
    self.coupon_code = CouponCode.where(id: self.coupon_code_id).first if self.coupon_code_id

    unless self.coupon_code.nil?
      if self.coupon_code.bound_user?
        self.coupon_code.use
      else
        self.coupon_code.bind_order_user_and_use
      end
    end
  end

  def content
    self.order_items.map {|i| "#{i.name}x#{i.quantity}"}.join(';')
  end

  def coupon_text
    unless self.coupon_code.nil?
      coupon = self.coupon_code.coupon
      "#{coupon.price} -> #{coupon.name} #{coupon.note}"
    end
  end

  need_aftermath :confirm_payment!, :refund_to_balance!, :refund!, :confirm_free!

  private

  def after_confirm
  end

  def log(type, text)
    getter_field = :"#{type}_note"
    setter_field = :"#{type}_note="

    if self.send(getter_field).present?
      text = " | #{text}"
    else
      self.send(setter_field, '')
    end

    self.send(setter_field, text)
  end

  class<< self
    def build_order(user, params = {})
      params ||= {}
      order = user.orders.build params
      order.add_items_from_cart user.cart_items

      if order.items_price > 500 || order.use_sf?
        order.deliver_by = :sf
      else
        order.deliver_by = :zt
      end

      order.cal_and_set_consumable_bong_point

      order.deliver_price = order.calculate_deliver_price

      # 优惠券和bong活跃点互斥
      if order.bong_point == 0
        order.set_coupon!
      end

      order
    end

    def cleanup_expired_orders
      pending.each do |o|
        if o.created_at + o.valid_period_days.days < Date.today
          begin
            o.close!
          rescue
            next
          end
        end
      end
    end
  end
end
