# encoding: utf-8
class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order
  belongs_to :user

  field :name, type: String
  field :note, type: String
  field :code, type: String

  field :status, type: Symbol, default: :available
  STATUS = {
    disabled: '已禁用',
    available: '可使用',
    used: '已使用',
    expired: '已过期'
  }
  validates :status, presence: true, inclusion: {in: STATUS.keys}

  scope :available, -> { where status: :available }

  validates :name, :code, presence: true
  validates_uniqueness_of :code

  def usable?(order)
    true # abstract stub
  end

  def take_effect(order)
    # abstract stub
  end

  def available?
    self.status == :available
  end

  def use!(order)
    return false unless self.user.nil? || self.user == order.user
    bind_user! order.user

    return false unless self.available? && usable?(order)

    order.coupon = self
    take_effect order
    order.sync_price
    order.save

    self.status = :used
    self.save
  end

  def bind_user!(user)
    return false unless self.user.nil?
    self.user = user
    save
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
    where(code: code, status: :available).first
  end
end
