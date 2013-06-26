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

  attr_reader :handler

  delegate :share, :follow, :topic_wrapper, :parse_image, :to => :handler, :allow_nil => true

  after_initialize :initialize_auth_handler

  def initialize_auth_handler
    @handler = "#{provider}_auth_handler".classify.constantize.
        new access_token: self.access_token, expires_at: self.expires_at, access_secret: self.access_token_secret
  end

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
end
