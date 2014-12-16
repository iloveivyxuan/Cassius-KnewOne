class Merchant
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  field :description, type: String

  field :meiqia, type: String

  field :customer_service, type: String
  field :customer_service_type, type: String # script or link

  before_save :meiqia_script

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

  private

  def meiqia_script
    return if customer_service.blank?
    return unless customer_service.include?('meiqia')
    return if customer_service.include?("&btn=hide")
    arr = customer_service.split("\"")
    arr[-2].concat("&btn=hide")
    self.customer_service = arr.join
  end
end
