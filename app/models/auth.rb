# -*- coding: utf-8 -*-
class Auth
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :access_token, type: String
  field :access_token_secret, type: String
  field :refresh_token, type: String
  field :expires_at, type: Time
  field :nickname, type: String, default: ""
  field :location, type: String, default: ""
  field :description, type: String, default: ""
  field :urls, type: Hash, default: {}
  field :avatar_url, type: String

  embedded_in :user

  validates :provider, presence: true
  validates :uid, presence: true

  delegate :share, :follow, :topic_wrapper, :friend_ids, :to => :handler, :allow_nil => true

  def handler
    @handler ||= "#{provider}_auth_handler".classify.constantize.
        new access_token: self.access_token, expires_at: self.expires_at, access_secret: self.access_token_secret
  end

  PROVIDERS = {
      'weibo' => '新浪微博',
      'twitter' => 'Twitter'
  }

  def expired?
    return true if self.access_token.blank?
    return false if self.expires_at.blank?
    Time.now > self.expires_at
  end

  def friends_on_site
    User.where(:'auths.provider' => self.provider, :'auths.uid'.in => friend_ids(self.uid).map(&:to_s))
  end

  class << self
    def from_omniauth(data)
      new omniauth_to_auth(data)
    end

    def omniauth_to_auth(data)
      {
          provider: data[:provider],
          uid: data[:uid].to_s,
          name: data[:info][:name],
          access_token: data[:credentials][:token],
          access_token_secret: data[:credentials][:secret],
          refresh_token: data[:credentials][:refresh_token],
          expires_at: data[:credentials][:expires_at],
          nickname: data[:info][:nickname],
          description: data[:info][:description],
          location: data[:info][:location],
          urls: data[:info][:urls],
          avatar_url: "#{data[:provider]}_auth_handler".classify.constantize.parse_image(data)
      }
    end
  end

  def update_from_omniauth(data)
    update Auth.omniauth_to_auth(data)
  end
end
