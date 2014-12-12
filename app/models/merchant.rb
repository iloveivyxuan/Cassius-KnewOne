class Merchant
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  field :description, type: String

  field :meiqia, type: String

  has_many :owners, class_name: "User"
  has_many :things
  has_one :group

  def group_id
    self.group.try(:id)
  end

  def role?(user)
    return unless user
    true if user.role?(:editor) || self.owners.include?(user)
  end

  def owner_names
    self.owners.map(&:name).join(',')
  end
end
