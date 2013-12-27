class Investor
  include Mongoid::Document

  field :amount, type: BigDecimal, default: 0
  embedded_in :thing
  belongs_to :user
end
