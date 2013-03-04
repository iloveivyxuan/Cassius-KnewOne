class Auth
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: Integer
  field :name, type: String
  field :access_token, type: String
  field :access_token_secret, type: String
  field :expires_at, type: Time
  field :nickname, type: String, default: ""
  field :location, type: String, default: ""
  field :description, type: String, default: ""
  field :urls, type: Hash, default: {}

  embedded_in :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :name, presence: true

  class << self
    def from_omniauth(data)
      new omniauth_to_auth(data)
    end

    def omniauth_to_auth(data)
      {
        provider: data[:provider],
        uid: data[:uid],
        name: data[:info][:name],
        access_token: data[:credentials][:token],
        access_secret: data[:credentials][:secret],
        expires_at: data[:credentials][:expires_at],
        nickname: data[:info][:nickname],
        description: data[:info][:description],
        location: data[:info][:location],
        urls: data[:info][:urls]
      }
    end
  end

  def update_from_omniauth(data)
    update_attributes Auth.omniauth_to_auth(data)
  end

  def parse_image(data)
    send "#{provider}_image", data
  end

  def weibo_image(data)
    data[:extra][:raw_info][:avatar_large] + ".jpg"
  end

  def twitter_image(data)
    data[:info][:image].sub('_normal', '')
  end

  def share(content)
    send "#{provider}_share", content
  end

  def follow
    method = "#{provider}_follow"
    send method if respond_to? method
  end

  def weibo_share(content)
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash(access_token: access_token, expires_at: expires_at)
    begin
      client.statuses.update content
    rescue OAuth2::Error
    end
  end

  def twitter_share(content)
    Twitter.configure do |config|
      config.oauth_token = access_token
      config.oauth_token_secret = access_secret
    end

    client = Twitter::Client.new oauth_token: access_token,
      oauth_token_secret: access_secret
    client.update content
  end

  def weibo_follow
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash(access_token: access_token, expires_at: expires_at)
    begin
      client.friendships.create(uid: Settings.weibo.official_uid,
                                screen_name: Settings.weibo.official_screen_name)
    rescue OAuth2::Error
    end
  end

  def twitter_follow
    Twitter.configure do |config|
      config.oauth_token = access_token
      config.oauth_token_secret = access_secret
    end

    client = Twitter::Client.new oauth_token: access_token,
             oauth_token_secret: access_secret
    client.follow Settings.twitter.official_uid
  end
end
