# encoding: utf-8
class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :coupon_codes

  field :name, type: String
  field :note, type: String
  field :status, type: Symbol, default: :available
  STATUS = {
      disabled: '禁用',
      available: '可用'
  }
  validates :status, presence: true, inclusion: {in: STATUS.keys}
  validates :name, presence: true

  STATUS.keys.each do |s|
    scope s, -> { where status: s }
    define_method :"#{s}?" do
      status == s
    end
  end

  def use_condition(order)
    true # abstract stub
  end

  def take_effect(order, code)
    # abstract stub
  end

  def undo_effect(order)
    # abstract stub
  end

  def usable?(order)
    available? && use_condition(order)
  end

  def generate_code!(params = {})
    params[:code] ||= SecureRandom.uuid[0..7]
    if params[:expires_at].blank? || Date.parse(params[:expires_at]) <= Date.today
      params[:expires_at] = 1.year.since.to_date
    end

    coupon_codes.create(params)
  end
end
