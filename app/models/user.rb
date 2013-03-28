class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :omniauthable

  field :email,  type: String, default: ""
  field :name, type: String
  field :admin,  type: Boolean, default: false
  field :karma, type: Integer, default: 0
  mount_uploader :avatar, ImageUploader

  attr_accessible :email, :avatar

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
        user.name = auth.nickname
        user.remote_avatar_url = auth.parse_image(data)
      end
    end
  end

  def current_auth
    auths.first
  end

  def update_from_omniauth(data)
    auth = auths.where(provider: data[:provider]).first
    if auth
      auth.update_from_omniauth(data)
      self.name = auth.nickname
      self.remote_avatar_url = auth.parse_image(data)
      save
    end
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

  def send_message(receivers, message)
    message.senders << self
    receivers.each do |receiver|
      receiver.messages << message
    end
  end

  ## Groups
  has_many :found_groups, class_name: "Group", inverse_of: :founder
  has_and_belongs_to_many :groups, inverse_of: :members

  ## Karma & Rank
  def rank
    return 0 if karma < 0
    @rank ||= (Math.sqrt karma/10).floor
  end

  def progress
    return 0 if karma < 0
    @progress ||= (karma - rank.abs2*10).to_f*100 / ((rank+1).abs2*10 - rank.abs2*10).to_f
  end

  ## Guest
  has_one :guest

  def is_guest?
    Guest.where(user_id: id).present?
  end

  ## Pagination
  paginates_per 50
end
