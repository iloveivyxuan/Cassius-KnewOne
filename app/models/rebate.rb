class Rebate
  include Mongoid::Document

  embedded_in :order

  field :name, type: String
  field :price, type: BigDecimal, default: 0
  field :note, type: String

  validates :name, :price, presence: false
end
