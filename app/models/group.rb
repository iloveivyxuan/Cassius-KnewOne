class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  mount_uploader :avatar, AvatarUploader
  field :qualification, type: Symbol, default: :public

  validates :name, presence: true
  validates :qualification, inclusion: {in: [:private, :public]}

  has_many :topics

  embeds_many :members do
    def add(user, role)
      @base.members.delete_all user_id: user.id
      @base.members << Member.new(user_id: user.id, role: role)
    end
  end

  def is_admin?(user)
    members.where(user_id: user.id).exists?
  end
end
