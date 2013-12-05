# -*- coding: utf-8 -*-
class User
  include Mongoid::Document

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, :trackable

  field :name, type: String, :default => ''
  field :nickname, type: String, :default => ''
  field :description, type: String, :default => ''
  field :location, type: String, :default => ''
  field :karma, type: Integer, default: 0

  ## Database authenticatable
  field :email,              :type => String
  field :encrypted_password, :type => String

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  mount_uploader :avatar, AvatarUploader

  ## Omniauthable
  embeds_many :auths

  class << self
    def find_by_omniauth(data)
      where("auths.provider" => data[:provider])
        .and("auths.uid" => data[:uid].to_i).first
    end

    def create_from_omniauth(data)
      create do |user|
        auth = Auth.from_omniauth(data)
        user.auths << auth
        user.name = auth.name
        user.nickname = auth.nickname
        user.location = auth.location
        user.description = auth.description
        user.remote_avatar_url = auth.parse_image(data)
        user.password = Digest::MD5.hexdigest auth.access_token
      end
    end
  end

  def current_auth
    auths.first
  end

  def equal_auth_provider?(another_user)
    another_user.current_auth && current_auth.provider == another_user.current_auth.provider
  end

  def update_from_omniauth(data)
    auth = auths.where(provider: data[:provider]).first
    if auth
      auth.update_from_omniauth(data)
      self.name = auth.name
      self.nickname = auth.nickname
      self.location = auth.location
      self.description = auth.description
      self.remote_avatar_url = auth.parse_image(data)
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

  ## Features
  has_and_belongs_to_many :fancy_features, class_name: "Feature", inverse_of: :fanciers

  ## Lotteries
  has_many :lotteries, inverse_of: :winners

  ## Messageable
  embeds_many :messages

  def send_message(receivers, message)
    message.senders << self
    receivers.each do |receiver|
      receiver.messages << message
    end
  end

  ## Groups
  has_many :found_groups, class_name: "Group", inverse_of: :founder

  # Payment
  embeds_many :addresses
  embeds_many :cart_items
  has_many :orders

  def add_to_cart(param)
    item = self.cart_items.where(thing: param[:thing], kind_id: param[:kind_id]).first
    if item.nil?
      item = self.cart_items.build thing: param[:thing],
      kind_id: param[:kind_id], quantity: param[:quantity]
    else
      item.quantity_increment(param[:quantity].to_i)
    end
    item.save
  end

  # Coupon
  has_many :coupon_codes

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

  private

  def email_required?
    current_auth.nil?
  end
end
