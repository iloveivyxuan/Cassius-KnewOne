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
  field :topics_count, type: Integer, default: 0

  embeds_many :members do
    def add(user, role = :member)
      @base.members.destroy_all user_id: user.id
      @base.members << Member.new(user_id: user.id, role: role)
    end
  end
  field :members_count, type: Integer, default: 0

  def has_admin?(user)
    user and members.where(user_id: user.id).in(role: [:founder, :admin]).exists?
  end

  def has_member?(user)
    user and members.where(user_id: user.id).exists?
  end

  def founder
    member = members.where(role: :founder).first
    User.find member.user_id if member
  end
end
