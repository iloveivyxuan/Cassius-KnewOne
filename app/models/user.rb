# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, :trackable,
         :confirmable

  field :name, type: String, :default => ''
  field :site, type: String, :default => ''
  field :description, type: String, :default => ''
  field :location, type: String, :default => ''
  field :karma, type: Integer, default: 0
  field :auto_update_from_oauth, type: Boolean, default: true
  field :status, type: Symbol, default: :normal
  STATUS = {blocked: '锁定', watching: '特别观照(贬)', normal: '正常'}
  validates :status, inclusion: {in: STATUS.keys, allow_blank: false}
  STATUS.keys.each do |k|
    class_eval <<-EVAL
      def #{k}?
        self.status == :#{k}
      end
    EVAL
  end
  validates :name, presence: true, uniqueness: true,
            format: {with: /\A[^\s]+\z/, multiline: false, message: '昵称中不能包含空格。'}

  # Stats
  field :things_count, type: Integer, default: 0
  field :reviews_count, type: Integer, default: 0
  field :orders_count, type: Integer, default: 0
  field :expenses_count, type: Integer, default: 0

  field :admin_note, type: String, default: ''

  def refresh_stats!
    UserStatsWorker.perform_async(self.id.to_s)
  end

  ## Database authenticatable
  field :email, :type => String
  field :encrypted_password, :type => String

  ## Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

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

  mount_uploader :avatar, AvatarUploader

  ## Omniauthable
  embeds_many :auths

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
      if data[:uid].to_i == 0
        where('auths.provider' => data[:provider], 'auths.uid_str' => data[:uid]).first
      else
        where('auths.provider' => data[:provider], 'auths.uid' => data[:uid].to_i).first
      end
    end

    def create_from_omniauth(data)
      create! do |user|
        auth = Auth.from_omniauth(data)
        user.auths << auth
        user.name = (auth.name || auth.nickname).gsub(' ', '-')
        if User.where(name: user.name).size > 0 || user.name.blank?
          user.name += "x#{SecureRandom.uuid[0..2]}"
        end
        user.location = auth.location
        user.description = auth.description
        user.remote_avatar_url = auth.parse_image(data)
        # user.password = Digest::MD5.hexdigest auth.access_token
      end
    end

    def find_by_fuzzy_name(name)
      return all if name.blank?
      str = name.gsub /[^\u4e00-\u9fa5a-zA-Z0-9 -]+/, ''

      where(name: /^#{str}/i)
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
    auth = auths.where(provider: data[:provider]).first
    if auth
      auth.update_from_omniauth(data)
      if self.auto_update_from_oauth?
        self.name = (auth.name || auth.nickname).gsub(' ', '-')
        if self.name_was.include?("#{self.name}x")
          reset_name!
        elsif User.where(name: self.name).size > 1 || self.name.blank?
          self.name += "x#{SecureRandom.uuid[0..2]}"
        end

        self.location = auth.location
        self.description = auth.description
        self.remote_avatar_url = auth.parse_image(data)
      end
      save
    end
  end

  def update_from_oauth(data)
    auth = auths.where(provider: data[:provider]).first
    if auth
      auth.update(data)
      if self.auto_update_from_oauth?
        self.name = (auth.name || auth.nickname).gsub(' ', '-')
        if self.name_was.include?("#{self.name}x")
          reset_name!
        elsif User.where(name: self.name).size > 1 || self.name.blank?
          self.name += "x#{SecureRandom.uuid[0..2]}"
        end

        self.location = auth.location
        self.description = auth.description
        self.remote_avatar_url = auth.parse_image(data)
      end
      save
    end
  end

  ## Roles
  field :role, type: String, default: ""
  ROLES = %w[vip editor sale admin]

  def role?(base_role)
    ROLES.index(base_role.to_s) <= (ROLES.index(role) || -1)
  end

  def staff?
    %w(editor sale admin).include? self.role
  end

  ## Photos
  has_many :photos

  ## Posts
  has_many :posts, class_name: "Post", inverse_of: :author

  def things
    posts.where(_type: "Thing")
  end

  def reviews
    posts.where(_type: "Review")
  end

  ## Things
  has_and_belongs_to_many :fancies, class_name: "Thing", inverse_of: :fanciers
  has_and_belongs_to_many :owns, class_name: "Thing", inverse_of: :owners

  ## Lotteries
  has_many :lotteries, inverse_of: :winners

  ## Messageable
  embeds_many :messages

  ## Groups
  has_many :found_groups, class_name: "Group", inverse_of: :founder

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

  def balance
    BigDecimal.new(self.balance_cents) / 100
  end

  def recharge_balance!(value, note)
    cents = (value * 100).to_i

    # prevent overselling
    u = User.where(id: self.id.to_s, balance_cents: self.balance_cents).
        find_and_modify :$set => {balance_cents: (self.balance_cents + cents)}
    if u
      u.balance_logs<< DepositBalanceLog.new(value_cents: cents, note: note)
      reload
      true
    else
      false
    end
  end

  def refund_to_balance!(order, value, note)
    cents = (value * 100).to_i

    # prevent overselling
    u = User.where(id: self.id.to_s, balance_cents: self.balance_cents).
        find_and_modify :$set => {balance_cents: (self.balance_cents + cents)}
    if u
      u.balance_logs<< RefundBalanceLog.new(order: order, value_cents: cents, note: note)
      reload
      true
    else
      false
    end
  end

  def revoke_refund_to_balance!(order, value, note)
    cents = (value * 100).to_i

    # prevent overselling
    u = User.where(id: self.id.to_s, balance_cents: self.balance_cents).
        find_and_modify :$set => {balance_cents: (self.balance_cents - cents)}
    if u
      u.balance_logs<< RevokeRefundBalanceLog.new(order: order, value_cents: cents, note: note)
      reload
      true
    else
      false
    end
  end

  def expense_balance!(value, note)
    cents = (value * 100).to_i
    balance_cents = self.balance_cents

    return false if balance_cents < cents

    # prevent overselling
    u = User.where(id: self.id.to_s, balance_cents: balance_cents).
        find_and_modify :$set => {balance_cents: (balance_cents - cents)}
    reload
    if u && u.balance > 0
      u.balance_logs<< ExpenseBalanceLog.new(value_cents: cents, note: note)
      true
    else
      # TODO: rollback
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

  ## Pagination
  paginates_per 50

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
