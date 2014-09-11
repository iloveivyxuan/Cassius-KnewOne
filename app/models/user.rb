class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Aftermath

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, :trackable, :confirmable

  field :name, type: String, :default => ''
  field :gender, type: String
  field :site, type: String, :default => ''
  field :description, type: String, :default => ''
  field :location, type: String, :default => ''
  field :karma, type: Integer, default: 0
  field :auto_update_from_oauth, type: Boolean, default: true
  field :identities, type: Array, default: []
  field :flags, type: Array, default: []
  field :status, type: Symbol, default: :normal

  index name: 1

  field :accept_edm, type: Boolean, default: true
  scope :edm, -> { where accept_edm: true }

  STATUS = {blocked: '锁定', watching: '特别观照(贬)', normal: '正常'}
  validates :status, inclusion: {in: STATUS.keys, allow_blank: false}
  validates :gender, inclusion: {in: %w(男 女), allow_blank: true}
  STATUS.keys.each do |k|
    class_eval <<-EVAL
      def #{k}?
        self.status == :#{k}
      end
    EVAL
  end
  validates :name, presence: true, uniqueness: {case_sensitive: false},
            format: {with: /\A[^\s]+\z/, multiline: false, message: '不能包含空格'}

  RESERVED_WORDS = ['knewone', '知新创想', '牛玩']
  validate :name_cannot_include_reserved_words

  def name_cannot_include_reserved_words
    if !staff? && RESERVED_WORDS.any? { |word| name.downcase.include? word }
      errors.add(:name, '名字不和谐')
    end
  end

  private :name_cannot_include_reserved_words

  # Stats
  field :things_count, type: Integer, default: 0
  field :fancies_count, type: Integer, default: 0
  field :owns_count, type: Integer, default: 0
  field :reviews_count, type: Integer, default: 0
  field :feelings_count, type: Integer, default: 0
  field :followers_count, type: Integer, default: 0
  field :followings_count, type: Integer, default: 0
  field :groups_count, type: Integer, default: 0
  field :topics_count, type: Integer, default: 0
  field :orders_count, type: Integer, default: 0
  field :expenses_count, type: Integer, default: 0

  # Last contents product timestamp
  field :last_review_created_at, type: Time
  field :last_thing_created_at, type: Time
  field :last_feeling_created_at, type: Time

  field :admin_note, type: String, default: ''
  field :recommend_priority, type: Integer, default: 0
  field :recommend_note, type: String, default: ''

  index recommend_priority: -1, followers_count: -1

  ## Database authenticatable
  field :email, :type => String
  field :encrypted_password, :type => String

  index email: 1

  ## Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  index reset_password_token: 1

  ## Rememberable
  field :remember_created_at, :type => Time
  field :remember_token, :type => String

  index remember_token: 1

  ## Trackable
  field :sign_in_count, :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip, :type => String

  ## Confirmable
  field :confirmation_token, :type => String
  field :confirmed_at, :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email, :type => String # Only if using reconfirmable

  validates_format_of :unconfirmed_email, with: email_regexp, allow_blank: true

  index confirmation_token: 1

  mount_uploader :avatar, AvatarUploader

  ## Omniauthable
  embeds_many :auths
  index 'auths.uid' => 1

  scope :confirmed, -> { gt confirmed_at: 0 }

  def has_fulfilled_email?
    self.unconfirmed_email.present? || self.email.present?
  end

  def has_confirmed_email?
    self.unconfirmed_email.blank? && confirmed?
  end

  def can_sign_in_by_password?
    has_fulfilled_email? && self.encrypted_password.present?
  end

  class << self
    def find_by_omniauth(data)
      where('auths.provider' => data[:provider], 'auths.uid' => data[:uid].to_s).first
    end

    def create_from_omniauth(data)
      create! do |user|
        auth = Auth.from_omniauth(data)
        user.auths << auth

        user.set_profiles_by_auth(auth)
      end
    end

    def create_from_mobile_app(provider, profile)
      create! do |user|
        auth = Auth.from_profile(provider, profile)
        user.auths << auth

        user.set_profiles_by_auth(auth)
      end
    end

    def find_by_sequence(name)
      return all if name.blank?
      str = Regexp.escape(name.gsub(/[^\u4e00-\u9fa5a-zA-Z0-9_-]+/, ''))
      where(name: /^#{str}/i)
    end

    def find_by_fuzzy(name)
      return all if name.blank?
      str = Regexp.escape(name.gsub(/[^\u4e00-\u9fa5a-zA-Z0-9_-]+/, ''))
      where(name: /#{str}/i)
    end

    def active_users(limit)
      User.desc(:recommend_priority, :followers_count).limit(limit)
    end
  end

  def current_auth
    auths.first
  end

  def has_auth?(provider)
    auths.select { |a| a.provider == provider }.any?
  end

  def equal_auth_provider?(another_user)
    another_user.current_auth && current_auth.provider == another_user.current_auth.provider
  end

  def update_from_omniauth(data)
    if auth = auths.where(provider: data[:provider]).first
      auth.update_from_omniauth(data)

      if self.auto_update_from_oauth?
        set_profiles_by_auth(auth)
        save

        self.remote_avatar_url = auth.avatar_url
        save rescue Exception
      end
    end
  end

  def update_from_oauth(data)
    if auth = auths.where(provider: data[:provider]).first
      auth.update(data)

      if self.auto_update_from_oauth?
        set_profiles_by_auth(auth)
        save

        self.remote_avatar_url = auth.avatar_url
        save rescue Exception
      end
    end
  end

  def set_profiles_by_auth(auth)
    if self.name.blank?
      self.name = (auth.name || auth.nickname).try(:gsub, ' ', '-') || 'KnewOne小伙伴'
    end

    if (!persisted? && User.where(name: /^#{Regexp.escape(self.name)}$/i).size > 0) || self.name.blank?
      self.name += "x#{SecureRandom.uuid[0..4]}"
    end

    self.location = auth.location
    self.description = auth.description
    # self.remote_avatar_url = auth.avatar_url
    self.gender = case auth.gender
                    when 'm' then
                      '男'
                    when 'f' then
                      '女'
                    else
                      nil
                  end
  end

  ## Roles
  field :role, type: Symbol, default: ""
  ROLES_WITH_DESC = {vip: "大号", volunteer: "志愿者", editor: "编辑", sale: "销售", admin: "管理员"}
  ROLES = ROLES_WITH_DESC.keys
  STAFF = %i(editor sale admin)

  ROLES.each do |role|
    scope role, -> { where role: role }
  end

  def role?(base_role)
    ROLES.index(base_role) <= (ROLES.index(role) || -1)
  end

  scope :staff, -> { where :role.in => STAFF }
  def staff?
    STAFF.include? role
  end

  ## Photos
  has_many :photos

  ## Posts
  has_many :posts, class_name: "Post", inverse_of: :author

  # Adoption
  has_many :adoptions

  def things
    posts.where(_type: "Thing")
  end

  def reviews
    posts.where(_type: "Review").desc(:created_at)
  end

  def feelings
    posts.where(_type: "Feeling").desc(:created_at)
  end

  def topics
    posts.where(_type: "Topic").desc(:created_at)
  end

  ## Things
  has_and_belongs_to_many :owns, class_name: "Thing", inverse_of: :owners

  def makings
    Thing.where(maker: self).desc(:created_at)
  end

  ## Followings

  def followed?(user)
    self.followings.include? user
  end

  def follow(user)
    return if user == self
    self.followings<< user unless followed? user
  end

  def batch_follow(users)
    users.each { |u| follow u }
  end

  def unfollow(user)
    self.followings.delete user
  end

  ## Lotteries
  has_many :lotteries, inverse_of: :winners

  ##Dialogs
  include UserDialogs

  def self.send_welcome_message_to(user_id)
    user = User.where(id: user_id).first
    return unless user

    ceo = User.where(id: '50ffdd447373c2f015000001').first
    return unless ceo

    content = [
               "#{user.name} ，欢迎你加入 KnewOne 牛玩！",
               '我是沙沙，KnewOne 的 CEO。',
               'KnewOne 牛玩是一个分享高品质消费品和使用体验的社区。在这里，你可以发现和分享提高生活品质的新奇酷产品，结识更多品位相似的朋友，共同探索未来世界。当你看到喜欢的东西时候记得点<i class="fancy_icon"></i>标记下来，这样你会获得关于这个产品更多的信息，也可以将它加入你喜欢的列表，当你参与的越多，你从 KnewOne 收获的也会越多！',
               '点这里看看我们为你做的 <a href="http://knewone.com/about?from_ceo">KnewOne 牛玩上手指南</a>',
               '祝你玩儿的开心！'
              ].join("\n\n")

    ceo.send_private_message_to(user, content)
    ceo.dialog_with(user).destroy
  end

  after_create do
    User.delay_for(30.minutes).send_welcome_message_to(self.id)
  end

  # Payment
  embeds_many :addresses
  embeds_many :invoices
  embeds_many :cart_items
  has_many :orders

  def add_to_cart(param)
    thing_id = (param[:thing]||param[:thing_id])

    item = self.cart_items.where(thing: thing_id, kind_id: param[:kind_id]).first
    if item.nil?
      item = self.cart_items.build thing: thing_id,
                                   kind_id: param[:kind_id], quantity: param[:quantity]
    else
      item.quantity_increment(param[:quantity].to_i)
    end
    item.save
  end

  # Coupon
  has_many :coupon_codes

  # Balance
  # use cents store money because BigDecimal stored as string in MongoDB,
  # and when BigDecimal is a integer(e.g: 0), it can't be use for query.
  field :balance_cents, type: Integer, default: 0
  validates :balance_cents, :presence => true, numericality: {greater_than_or_equal_to: 0}
  embeds_many :balance_logs, cascade_callbacks: true

  # Draft
  has_many :drafts

  # ThingList
  has_many :thing_lists

  def related_thing_lists
    (thing_lists + fancied_thing_lists).uniq
  end

  def balance
    BigDecimal.new(self.balance_cents) / 100
  end

  def recharge_balance!(value, note)
    cents = (value * 100).to_i
    inc(balance_cents: cents)
    balance_logs << DepositBalanceLog.new(value_cents: cents, note: note)
    true
  end

  def refund_to_balance!(order, value, note)
    cents = (value * 100).to_i
    inc(balance_cents: cents)
    balance_logs << RefundBalanceLog.new(order: order, value_cents: cents, note: note)
    true
  end

  def revoke_refund_to_balance!(order, value, note)
    cents = (value * 100).to_i

    u = User
    .where(id: id, :balance_cents.gte => cents)
    .find_and_modify(:$inc => {balance_cents: -cents})

    if u
      balance_logs << RevokeRefundBalanceLog.new(order: order, value_cents: cents, note: note)
      reload
      true
    else
      false
    end
  end

  def expense_balance!(value, note)
    cents = (value * 100).to_i

    u = User
    .where(id: id, :balance_cents.gte => cents)
    .find_and_modify(:$inc => {balance_cents: -cents})

    if u
      balance_logs << ExpenseBalanceLog.new(value_cents: cents, note: note)
      reload
      true
    else
      false
    end
  end

  def has_balance?
    self.balance_cents > 0
  end

  ## Karma & Rank
  def rank
    return 0 if karma < 0
    @rank ||= (Math.sqrt karma/10).floor
  end

  def progress
    return 0 if karma < 0
    @progress ||= (karma - rank.abs2*10).to_f*100 / ((rank+1).abs2*10 - rank.abs2*10).to_f
  end

  # notification
  include NotificationReceivable

  ## Apple Push Notifications
  field :apple_device_token, type: String
  index apple_device_token: 1

  # activity
  include Feedable

  def related_activities(types = %i(new_thing own_thing fancy_thing
                                    new_review love_review
                                    new_feeling love_feeling))
    user_ids = following_ids + [self.id]
    Activity.where(:user_id.in => user_ids.map(&:to_s), :type.in => types, visible: true)
  end

  # category
  has_and_belongs_to_many :categories do
    def things
      Thing.published.any_in(categories: @target.map(&:name))
    end
  end

  # recommend users who not followed by self
  def recommend_new_users
    user_ids = following_ids + [self.id]
    User.nin(id: user_ids).desc(:recommend_priority, :karma)
  end

  # recommend users from oauth(only support weibo)
  def recommend_users(bilateral = false)
    if auth = auths.select { |a| a.provider == 'weibo' }.first
      auth.friends_on_site(bilateral).desc(:followers_count)
    end
  end

  # groups
  def joined_groups
    Group.find_by_user self
  end

  def managed_groups
    joined_groups.select { |g| g.has_admin? self }
  end

  include IdsSortable

  sort_by_ids :owns, Thing
  sort_by_ids :fancies, Thing

  need_aftermath :follow, :unfollow

  protected
  def password_required?
    self.encrypted_password.present? && (!password.nil? || !password_confirmation.nil?)
  end

  def confirmation_required?
    false
  end

  def send_confirmation_notification?
    self.unconfirmed_email.present? || (self.email.present? && !confirmed?)
  end

  def email_required?
    auths.empty?
  end
end
