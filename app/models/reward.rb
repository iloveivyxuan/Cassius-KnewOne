class Reward
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes

  field :user_id, type: String
  field :date, type: Date
  field :body, type: String
  field :reason, type: String
  field :coupon_id, type: String
  field :coupon_code_id, type: String

  validate do
    errors.add :user, '没有这个用户' unless user
  end

  validates :reason, presence: true

  slug :date do |doc|
    doc.date.to_s
  end

  default_scope -> { desc(:date) }
  scope :awarded, -> { where :coupon_code_id.ne => nil }

  def user
    return nil if self.user_id.blank?
    @user ||= User.find(self.user_id)
  end

  def coupon
    return nil if self.coupon_id.blank?
    @coupon ||= Coupon.find(self.coupon_id)
  end

  def coupon_code
    return nil if self.coupon_code_id.blank?
    @coupon_code = CouponCode.find(self.coupon_code_id)
  end

  def award!
    return false unless coupon

    self.coupon_code_id = coupon.generate_code!(expires_at: 3.months.since.to_date,
                                                admin_note: "#{self.date} #{self.user.name} 天天有礼").id.to_s
    save

    UserMailer.award(self.id.to_s).deliver
  end
end
