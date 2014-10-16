class Adoption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :note, type: String
  field :status, type: Symbol, default: :waiting

  belongs_to :user
  belongs_to :thing
  embeds_one :address

  after_build do
    build_address unless self.address
  end

  validates :status, inclusion: { in: [:waiting, :approved, :denied] }
  validates :user, presence: true, uniqueness: { scope: :thing }
  validates :thing, presence: true
  validates :address, presence: true
  validates_associated :address
end
