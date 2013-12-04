class CouponCode
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :coupon
  belongs_to :order
  belongs_to :user

  field :code, type: String
  field :used, type: Boolean, default: false
  field :expires_at, type: Date

  validates :code, presence: true, uniqueness: true

  delegate :name, :note, to: :coupon

  def bind_user!(user)
    return false unless self.user.nil?

    self.user = user

    save
  end

  def undo
    return false unless used?
    return false if self.order.nil?

    self.coupon.undo_effect(self.order)
    self.order.sync_price

    self.order = nil
    self.used = false

    save
  end


  def use
    return false if self.order.nil? && !usable?

    self.coupon.take_effect(self.order, self)
    self.used = true
    self.order.sync_price

    save
  end

  def bind_and_use_to_order!(order)
    return false if bind_user!(order.user)
    order.coupon_code = self
    use!
  end

  def usable?
    test?(self.order)
  end

  def test?(order)
    !self.used? && self.user == order.user && self.coupon.usable?(order)
  end

  def self.find_by_code(code)
    where(code: code).first
  end

  def self.find_unused_by_code(code)
    where(code: code, used: false).first
  end
end
