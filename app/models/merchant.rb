class Merchant
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  field :description, type: String

  belongs_to :user
  has_many :things
  has_one :group

  def group_id
    self.group.try(:id)
  end

  def role?(user)
    return unless user
    true if user.role?(:editor) || self.user == user
  end

  def user_name
    self.user.name
  end

  def user_name=(name)
    self.user = User.find_by(name: name)
  end
end
