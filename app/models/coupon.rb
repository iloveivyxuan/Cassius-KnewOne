class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :orders

  field :name, type: String
  field :note, type: String
  field :code, type: String
  field :available, type: Boolean, default: true

  scope :available, -> { where available: true }

  validates :name, :code, presence: true
  validates_uniqueness_of :code

  def usable?(order)
    true # abstract stub
  end

  def take_effect(order)
    # abstract stub
  end

  def use!(order)
    return false if orders.include?(order) || !usable?(order)

    order.coupons<< self
    take_effect order
    order.save
  end

  def disable!
    self.available = false
    self.save
  end

  def self.generate(params = {})
    params.merge!(code: SecureRandom.uuid[0..7]) if params[:code].blank?
    new params
  end

  def self.generate!(params)
    coupon = generate(params)
    coupon.save
    coupon
  end

  def self.find_available_by_code(code)
    where(code: code, available: true).first
  end
end
