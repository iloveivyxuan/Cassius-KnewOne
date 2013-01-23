class Auth
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: Integer
  field :name, type: String
  field :access_token, type: String
  field :expires_at, type: Time
  embedded_in :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :name, presence: true

  class << self
    def from_omniauth(data)
      new provider: data[:provider],
      uid: data[:uid],
      name: data[:info][:name],
      access_token: data[:credentials][:token],
      expires_at: data[:credentials][:expires_at]
    end
  end

  def standize(data)
    provider_extra = data[:provider] + "_extra"
    data = send provider_extra, data if respond_to? provider_extra
    data
  end

  def weibo_extra(data)
    data[:info][:image] = data[:extra][:raw_info][:avatar_large] + ".jpg"
    data
  end

  def url
    method = "#{provider}_url".to_sym
    send method if respond_to? method
  end

  def share(content)
    method = "#{provider}_share".to_sym
    send method, content if respond_to? method
  end

  def weibo_url
    "http://weibo.com/u/#{uid}"
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
