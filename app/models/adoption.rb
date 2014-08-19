class Adoption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :note, type: String
  field :status, type: Symbol, default: :waiting
  field :kind_id, type: String
  field :adoption_no, type: String

  validates :status, inclusion: { in: [:waiting, :approved, :denied] }

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

end
