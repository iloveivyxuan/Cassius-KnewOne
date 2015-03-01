class User
  include Mongoid::Document
  include Mongoid::Timestamps

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
  scope :edm, -> { where :accept_edm => true, :email.exists => true }

  field :part_time_list, type: Array, default: []

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

  validates :name, uniqueness: {case_sensitive: false}, allow_blank: false
  validates :name, format: {with: /\A[^\s]+\z/, multiline: false, message: '不能包含空格'}, allow_blank: true
  validates :name, length: {in: 1..20}, if: -> { self.auths.empty? }, allow_blank: false

  RESERVED_WORDS = ['knewone', '知新创想', '牛玩']
  validate :name_cannot_include_reserved_words

  def name_cannot_include_reserved_words
    return if self.name.blank?

    if !staff? && RESERVED_WORDS.any? { |word| name.downcase.include? word }
      errors.add(:name, '名字不和谐')
    end
  end

  private :name_cannot_include_reserved_words

  # Stats
  field :things_count, type: Integer, default: 0
  field :reviews_count, type: Integer, default: 0
  field :feelings_count, type: Integer, default: 0
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
  index recommend_priority: -1, karma: -1

  ## Database authenticatable
  field :email, :type => String
  field :encrypted_password, :type => String

  index({email: 1}, {unique: true, sparse: true})

  def unset_blank_email
    unset(:email) if email.blank?
  end
  before_validation :unset_blank_email
  private :unset_blank_email

  # most failure mail send is email inlcuding space
  def clean_space_in_email
    self.unconfirmed_email.gsub!(' ', '') if self.unconfirmed_email.present?
    self.email.gsub!(' ', '') if self.email.present?
  end
  before_validation :clean_space_in_email
  private :clean_space_in_email

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
  index unconfirmed_email: 1

  mount_uploader :avatar, AvatarUploader
  skip_callback :save, :after, :remove_previously_stored_avatar
  scope :only_with_avatars, -> { only(:id, :name, :avatar) }

  CANOPYS = [
    'http://image.knewone.com/photos/0e8d53847adc2b1e78740c55e553eefa.jpg',
    'http://image.knewone.com/photos/71a9c6b6b64def98c19f0c19f399cfba.jpg', 
    'http://image.knewone.com/photos/dd2699adc803ccf0420f442b29674d79.jpg', 
    'http://image.knewone.com/photos/2baffd379fed9420af647ceefabf1256.jpg', 
    'http://image.knewone.com/photos/a3feeac5922c1ca976e32463360ccc6b.jpg', 
    'http://image.knewone.com/photos/ea4d728679d3d14db4ae2c988e5c307a.jpg', 
    'http://image.knewone.com/photos/1c5228b8da2d5b38ea355a6a7bb58dc0.jpg', 
    'http://image.knewone.com/photos/417630b019e3c3a180b510d1c7ad5bb4.jpg'
  ]
  field :canopy, type: String, :default => "http://image.knewone.com/photos/cebdb91be4a5334148ecb29c2bf18f83.jpg"

  ## Omniauthable
  embeds_many :auths
  index 'auths.uid' => 1

  scope :confirmed, -> { gt confirmed_at: 0 }
  scope :authorized, -> { where(:identities.with_size => 1) }

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

        user.set_profiles_by_auth(auth)

        user.auths << auth
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
      if data[:info]
        auth.update_from_omniauth(data)
      else
        auth.update data
      end

      if self.auto_update_from_oauth?
        set_profiles_by_auth(auth)
        save

        if auth.avatar_url.present?
          self.remote_avatar_url = auth.avatar_url
          save rescue Exception
        end
      end
    end
  end

  def set_profiles_by_auth(auth)
    if self.name.blank?
      self.name = (auth.name || auth.nickname).try(:gsub, ' ', '-')
    end

    if self.name.present? && (!persisted? && User.where(name: /^#{Regexp.escape(self.name)}$/i).exists?)
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

  def makings
    Thing.where(maker: self).desc(:created_at)
  end

  ##Dialogs
  include UserDialogs

  def self.send_welcome_message_to(user_id)
    user = User.where(id: user_id).first
    return unless user

    ceo = User.where(id: '50ffe1107373c2f015000003').first
    return unless ceo

    content = <<HERE
Hi，#{user.name} ，欢迎来到 KnewOne

KnewOne 是探讨科技与设计相关产品的社区，在这里你可以：

－发布令你印象深刻的产品
－发表你对产品的感受和使用体验
－从多达上万件的产品库中选择符合你生活品味的产品做成列表，分享给朋友们

当你参与越多，就越容易在 KnewOne 找到适合你的产品和品味相近的朋友

通过 <a href="http://knewone.com/about">KnewOne 指南</a> 可以更多地了解我们，<b>现在就来探索 KnewOne 吧</b>
HERE

    ceo.send_private_message_to(user, content)
    ceo.dialog_with(user).destroy
  end

  after_create do
    User.delay_for(rand(10.minutes)).send_welcome_message_to(self.id)
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
  has_many :thing_lists, inverse_of: :author

  belongs_to :merchant, counter_cache: true

  def related_thing_lists
    (thing_lists + fancied_thing_lists).uniq
  end

  # Impressions
  has_many :impressions, inverse_of: :author

  field :fancies_count, type: Integer, default: 0
  field :desires_count, type: Integer, default: 0
  field :owns_count, type: Integer, default: 0

  def impression_of(thing)
    impressions.of_thing(thing).first
  end

  def fancy_ids
    @_fancy_ids ||= impressions.fancied.pluck(:thing_id)
  end

  def desire_ids
    @_desire_ids ||= impressions.desired.pluck(:thing_id)
  end

  def own_ids
    @_own_ids ||= impressions.owned.pluck(:thing_id)
  end

  def fancies
    @_fancies ||= Thing.in(id: fancy_ids)
  end

  def desires
    @_desires ||= Thing.in(id: desire_ids)
  end

  def owns
    @_owns ||= Thing.in(id: own_ids)
  end

  include IdsSortable

  sort_by_ids :owns, Thing
  sort_by_ids :desires, Thing
  sort_by_ids :fancies, Thing
  sort_by_ids :followings, User
  sort_by_ids :followers, User

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

  # activity & relationship
  include Feedable

  # category
  has_and_belongs_to_many :categories, inverse_of: nil do
    def things
      Thing.published.any_in(categories: @target.map(&:name))
    end
  end

  # tags
  has_and_belongs_to_many :tags, inverse_of: nil

  def recent_tags(limit = nil)
    tag_ids = self.tag_ids
    tag_ids = tag_ids.take(limit) if limit
    Tag.in(id: tag_ids).sort_by { |tag| tag_ids.index(tag.id) }
  end

  # recommend users who not followed by self
  def recommend_new_users
    user_ids = following_ids + [self.id]
    User.only(:id, :name, :avatar, :recommend_note).nin(id: user_ids).desc(:recommend_priority, :karma)
  end

  # recommend users from oauth(only support weibo)
  def recommend_users(bilateral = false)
    if auth = auths.select { |a| a.provider == 'weibo' }.first
      auth.friends_on_site(bilateral).desc(:followers_count)
    end
  end

  # groups
  def joined_groups
    Group.find_by_user(self).sort_by { |g| g.members.find_by(user_id: self.id).created_at || Time.at(0) }.reverse
  end

  def managed_groups
    joined_groups.select { |g| g.has_admin? self }
  end

  # bong
  def bong_bind?
    !!bong_auth
  end

  def bong_auth
    @_bong_auth ||= self.auths.where(provider: 'bong').first
  end

  def bong_client
    @_bong_client ||= BongClient.new access_token: bong_auth.access_token, uid: bong_auth.uid
  end

  # wechat
  def wechat_bind?
    !!wechat_auth
  end

  def wechat_auth
    @_wechat_auth ||= self.auths.where(provider: 'wechat').first
  end

  def self.related_users_and_owned(thing, user, count, fields = [:id, :name])
    related_user_ids = (user.following_ids & thing.owner_ids).take(count)
    related_users = User.only(fields).in(id: related_user_ids).desc(:karma)

    return related_users if related_user_ids.size >= [count, thing.owners_count].min

    other_owner_ids = (thing.owner_ids - related_user_ids).take(count - related_users.size)
    other_owners = User.only(fields).in(id: other_owner_ids).desc(:karma)

    related_users + other_owners
  end

  def has_been_invited_by?(user, thing)
    Activity.by_users([user])
      .by_type(:invite_review)
      .by_reference(self)
      .by_source(thing)
      .exists?
  end

  def can_set_topic_top?(group)
    self.role?(:editor) || group.has_admin?(self) || self == group.founder
  end

  include Searchable

  searchable_fields [:name]

  mappings do
    indexes :name, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
  end

  alias_method :_as_indexed_json, :as_indexed_json
  def as_indexed_json(options={})
    _as_indexed_json(options).merge(avatar_url: avatar.url, weight: rank)
  end

  def self.search(query)
    query_options = {
      function_score: {
        query: {
          multi_match: {
            query: query,
            fields: ['name^3', 'ngram']
          }
        },
        field_value_factor: {
          field: 'weight',
          modifier: 'log2p'
        }
      }
    }

    __elasticsearch__.search(query: query_options)
  end

  def __elasticsearch__.__find_in_batches(options={}, &block)
    batch_size = options[:batch_size] || 1000
    User.no_timeout.only(:id, :name, :avatar, :karma).each_slice(batch_size, &block)
  end

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
