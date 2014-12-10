class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String
  field :description, type: String
  mount_uploader :avatar, AvatarUploader
  field :qualification, type: Symbol, default: :public

  scope :public, -> {where qualification: :public}

  validates :name, presence: true
  validates :qualification, inclusion: {in: [:private, :public]}

  has_many :topics, dependent: :destroy
  field :topics_count, type: Integer, default: 0

  field :visible, type: Boolean, default: true
  scope :visible, -> { where visible: true }

  field :approved, type: Boolean, default: false
  scope :approved, -> { where approved: true }

  belongs_to :merchant

  embeds_many :members do
    def add(user, role = :member)
      unless @base.has_member? user
        @base.members.create user_id: user.id, role: role
      end
    end

    def remove(user)
      @base.members.where(user_id: user.id).destroy
    end
  end
  field :members_count, type: Integer, default: 0

  class << self
    def find_by_user(user)
      where('members.user_id' => user.id.to_s)
    end

    def find_by_fuzzy_name(name)
      return all if name.blank?
      str = name.gsub /[^\u4e00-\u9fa5a-zA-Z0-9_-]+/, ''
      where(name: /^#{Regexp.escape(str)}/i)
    end
  end

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

  def public?
    qualification == :public
  end

  def private?
    qualification == :private
  end
end
