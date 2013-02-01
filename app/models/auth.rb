class Auth
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: Integer
  field :name, type: String
  field :access_token, type: String
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
    provider_image = provider + "_image"
    image = send provider_image, data if respond_to? provider_image
    image
  end

  def weibo_image(data)
    data[:extra][:raw_info][:avatar_large] + ".jpg"
  end

  def twitter_image(data)
    data[:info][:image].sub('_normal', '')
  end

  def share(content)
    method = "#{provider}_share".to_sym
    send method, content if respond_to? method
  end

  def weibo_share(content)
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash(access_token: access_token, expires_at: expires_at)
    begin
      client.statuses.update content
    rescue OAuth2::Error
    end
  end
end
