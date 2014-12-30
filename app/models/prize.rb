class Prize
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :name, type: String

  field :since, type: Date
  field :due, type: Date

  field :reason, type: String

  field :user_id, type: String
  field :coupon_id, type: String
  field :coupon_code_id, type: String

  field :reference_id, type: String

  scope :valid, -> { where :coupon_code_id.ne => nil }

  def user
    return nil if user_id.blank?
    User.where(id: user_id).first
  end

  def coupon
    return nil if coupon_id.blank?
    Coupon.where(id: coupon_id).first
  end

  def coupon_code
    return nil if coupon_code_id.blank?
    CouponCode.where(id: coupon_code_id).first
  end

  def date_text
    since.to_s
  end

  def surprise!
    return false unless coupon

    self.coupon_code_id = coupon.generate_code!(expires_at: 3.months.since.to_date,
                                                admin_note: "#{self.date_text} #{self.user.name} 天天有礼").id.to_s
    save

    # mailer
    UserMailer.prize(self.id.to_s).deliver
    # direct message
    knewone = User.find "511114fa7373c2e3180000b4"
    user = self.user
    return unless knewone && user
    content = "药药药！#{user.name}，你上天天有礼啦！这是一张 #{self.coupon.name} 优惠券快收好：#{self.coupon_code.code}，默念 KnewOne 大法好保平安~"
    content += "<a href='http://knewone.com/settings/coupons?code=#{self.coupon_code.code}'>点此绑定到您的 KnewOne 账号上</a>"
    knewone.send_private_message_to(user, content)
  end

  def self.reason_collection
    %w(分享了最多的产品 分享的优质产品排名第二 分享的优质产品排名第三 分享的优质产品排名第四 创建优质列表 撰写优质评测 分享超过5个产品)
  end

  def self.coupon_ids
    %w(549d13dd31302d197fb10000 549d13f331302d199b510000 549d140131302d1989600000 549d140f31302d19a9560000)
  end

  def self.share_things(day=Date.yesterday)
    share_things = {}
    Thing.created_between(day, day.next_day).approved.group_by(&:author).each do |action|
      share_things[action.first] = action.last.size
    end
    share_things.sort_by { |k, v| v }.reverse.select { |user, size| user.role.blank? }
  end

  def self.share_reviews(day=Date.yesterday)
    share_reviews = {}
    Review.created_between(day, day.next_day).living.group_by(&:author).each do |action|
      share_reviews[action.first] = action.last.size
    end
    share_reviews.sort_by { |k, v| v }.reverse.select { |user, size| user.role.blank? }
  end

  def self.share_lists(day=Date.yesterday)
    share_lists = {}
    ThingList.created_between(day, day.next_day).group_by(&:author).each do |action|
      share_lists[action.first] = action.last.size
    end
    share_lists.sort_by { |k, v| v }.reverse.select { |user, size| user.role.blank? && size > 1 }
  end

  def self.generate_day_prize(day=Date.yesterday)
    things = Prize.share_things(day)
    review = Prize.share_reviews(day).first
    list = Prize.share_lists(day).first
    # 优秀产品
    things.take(4).each_with_index do |action, index|
      user = action.first
      reason = Prize.reason_collection[index]
      coupon = (index > 0) ? Prize.coupon_ids[index - 1] : nil
      Prize.create(
                   name: "产品",
                   since: day,
                   due: day,
                   reason: reason,
                   user_id: user.id.to_s,
                   coupon_id: coupon)
    end
    # 超过 5 个产品
    others = things[4..-1]
    if others
      others.each do |action|
        user = action.first
        reason = Prize.reason_collection.last
        coupon = Prize.coupon_ids.last
        Prize.create(
                     name: "产品",
                     since: day,
                     due: day,
                     reason: reason,
                     user_id: user.id.to_s,
                     coupon_id: coupon)
      end
    end
    # 优秀列表
    Prize.create(
                 name: "列表",
                 since: day,
                 due: day,
                 reason: "分享了最多的优质列表",
                 user_id: list.first.id.to_s) if list
    # 优秀评测
    Prize.create(
                 name: "评测",
                 since: day,
                 due: day,
                 reason: "分享了最多的优质评测",
                 user_id: review.first.id.to_s) if review
  end
end
