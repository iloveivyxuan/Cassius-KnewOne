class Merchant
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  field :description, type: String

  field :customer_service, type: String
  field :customer_service_type, type: String # script or link

  before_save :meiqia_script

  has_many :owners, class_name: "User"
  field :owners_count, type: Integer, default: 0

  has_many :things
  field :things_count, type: Integer, default: 0

  has_one :group

  after_save :update_counter_cache

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
    regex = /unitid=([0-9]+)/.match(customer_service)
    self.customer_service = "<script async='true' src='https://s.meiqia.com/js/mechat.js?unitid=#{regex[1]}&btn=hide' charset='UTF-8'></script>"
  end

  def update_counter_cache
    set(owners_count: owners.size)
    set(things_count: things.size)
  end
end
