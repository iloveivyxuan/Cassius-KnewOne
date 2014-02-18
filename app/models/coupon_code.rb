class CouponCode
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :coupon
  belongs_to :order
  belongs_to :user

  field :code, type: String
  field :used, type: Boolean, default: false
  field :admin_note, type: String
  field :expires_at, type: Date

  validates :code, presence: true, uniqueness: true

  delegate :name, :note, to: :coupon

  scope :unused, -> { where(:used => false) }

  def bind_user!(user)
    return false unless self.user.nil?

    self.user = user

    save
  end

  def bound_user?
    !self.user.nil?
  end

  def undo
    return false unless used?
    return false if self.order.nil?

    self.coupon.undo_effect(self.order)
    self.order.sync_price

    # self.order = nil
    self.used = false
  end

  def use
    return false if self.order.nil? && !usable?

    self.used = true

    self.coupon.take_effect(self.order, self)
    self.order.sync_price
  end

  def bind_order_user_and_use
    return false unless self.user.nil?

    self.user = self.order.user

    use
  end

  def usable?
    test?(self.order)
  end

  def test?(order)
    !expired? && (!used_was || !self.used?) && self.user == order.user && self.coupon.usable?(order)
  end

  def expired?
    return false unless self.expires_at
    Time.now > self.expires_at
  end

  def self.find_by_code(code)
    where(code: code).first
  end

  def self.find_unused_by_code(code)
    where(code: code, used: false).first
  end
end
