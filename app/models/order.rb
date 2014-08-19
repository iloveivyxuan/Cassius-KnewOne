class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  include Aftermath

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

  scope :by_thing_kind, ->(kind) { where 'order_items.thing_id' => kind.thing.id, 'order_items.kind_id' => kind.id.to_s }
  scope :by_thing, ->(thing) { where 'order_items.thing_id' => thing.id }

  scope :from_date, ->(date) { where :created_at.gte => date.to_time.to_i }
  scope :to_date, ->(date) { where :created_at.lt => date.next_day.to_time.to_i }

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
      :shipped => '已发货',
      :canceled => '订单取消',
      :closed => '订单关闭',
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
      # same as https://code.google.com/p/kuaidi-api/wiki/Open_API_API_URL
      :yuantong => '圆通速递',
      :debangwuliu => '德邦物流',
      :huitongkuaidi => '百世汇通',
      :shunfeng => '顺丰速递',
      :zhongtong => '中通速递'
  }
  PAYMENT_METHOD = {
      :tenpay => '财付通',
      :alipay => '支付宝',
      :btc => '比特币',
      :other => '其它'
  }

  field :state, type: Symbol, default: :pending
  field :payment_method, type: Symbol
  field :order_no, type: String
  field :deliver_by, type: Symbol
  field :deliver_no, type: String
  field :note, type: String
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
    self.pre_order = order_items.all? {|i| i.kind.stage == :pre_order}

    # mongoid may not rollback when error occurred
    order_items.each &:claim_stock!
    sync_price

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
    self.user.cart_items.where(:thing.in => order_items.map(&:thing), :kind_id.in => order_items.map(&:kind).map(&:id)).destroy_all

    confirm_free! if can_confirm_free?

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

  # There is a situation is user closed or canceled order, but still paid at third party
  # IMPORTANT: stock
  def can_confirm_payment?
    pending? || canceled? || closed?
  end

  def can_pay?
    pending?
  end

  def can_confirm_free?
    (freed? || self.expense_balance == total_price) && freed?
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

  def can_refunded_balance_to_platform?
    refunded_to_balance?
  end

  def confirm_payment!(trade_no, price, method, raw)
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

    order_histories.create from: :pending, to: :closed
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
    return 0 if self.deliver_by.nil?
    self.deliver_by = :bong_delivery if self.bong_inside?
    return 10 if self.deliver_by == :bong_delivery
    (self.deliver_by == :zt || items_price > 500) ? 0 : SF_PRICE
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
    bong && self.order_items.where(thing_title: bong.title).exists?
  end

  need_aftermath :confirm_payment!, :refund_to_balance!, :refund!, :confirm_free!

  private

  def after_confirm
    self.user.inc karma: Settings.karma.order
    # bong coupon
    if bong_inside?
      coupons = bong_coupon(bong_amount)
      order_note = coupons.map(&:code)
      leave_note(order_note)
    end
  end

  def bong
    @_bong ||= Thing.where(id: "53d0bed731302d2c13b20000").first
  end

  def bong_amount
    self.order_items.where(thing_id: bong.id).map(&:quantity).reduce(&:+)
  end

  def leave_note(notes)
    message = "您已经获得："
    notes.each_with_index do |note, index|
      if index.even?
        message += "满 200 减 50 优惠券 #{note} ，"
      else
        message += "满 200 减 49 优惠券 #{note} ，"
      end
    end
    message += "进入 控制面板-优惠券 页面绑定即可使用，有效期至 #{3.months.since.to_date}（三个月）。"
    self.update_attributes(note: message)
  end

  def bong_coupon(amount)
    coupons = []
    @bong = Thing.find_by(title: bong.title)
    rebate_coupon_50 = AbatementCoupon.find_or_create_by(bong_abatement_coupon_params 50)
    rebate_coupon_49 = AbatementCoupon.find_or_create_by(bong_abatement_coupon_params 49)
    amount.times do |time|
      coupons << rebate_coupon_50.generate_code!(bong_coupon_code_params)
      coupons << rebate_coupon_49.generate_code!(bong_coupon_code_params)
    end
    coupons
  end

  def bong_abatement_coupon_params(price)
    {
      name: "满 200 减 #{price} 优惠券",
      note: "购物满 200 元结算时输入优惠券代码立减 #{price} 元",
      threshold_price: 200,
      price: price
    }
  end

  def bong_coupon_code_params
    {
      expires_at: 3.months.since.to_date,
      admin_note: "通过购买 bong II 获得",
      generator_id: self.user.id.to_s
    }
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

      order
    end

    def cleanup_expired_orders
      pending.each do |o|
        if o.created_at + o.valid_period_days.days < Date.today
          o.close!
        end
      end
    end
  end
end
