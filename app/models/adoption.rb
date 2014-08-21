class Adoption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :note, type: String
  field :status, type: Symbol, default: :waiting
  field :kind, type: String
  field :adoption_no, type: String

  validates :kind, presence: true

  validates :status, inclusion: { in: [:waiting, :approved, :denied] }

  after_save :inc_adoptions_count

  belongs_to :user
  belongs_to :thing

  embeds_one :address

  attr_accessor :address_id
  alias_method :_address=, :address=

  def address=(val)
    return nil unless val

    self.address_id = val.id.to_s
    self._address = val
  end

  def self.build_adoption(user, params = {})
    params ||= {}
    adoption = user.adoptions.build params
    adoption
  end

  def has_adopted_by? user
    user.adoptions.where(id: self.id).exists?
  end

  def inc_adoptions_count
    self.user.update_attributes(adoptions_count: self.user.adoptions_count + 1)
  end

end
