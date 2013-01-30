class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :omniauthable

  field :email,              type: String, default: ""
  field :name,               type: String, default: ""
  field :admin,  type: Boolean, default: false
  field :description, type: String, default: ""
  mount_uploader :avatar, ImageUploader

  attr_accessible :email, :name, :description, :avatar

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
        data = auth.standize(data)
        user.name = data[:info][:name]
        user.description = data[:info][:description]
        user.remote_avatar_url = data[:info][:image]
      end
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
end
