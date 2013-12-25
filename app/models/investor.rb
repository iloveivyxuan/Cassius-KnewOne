class Investor
  include Mongoid::Document

  field :amount, type: BigDecimal
  embedded_in :thing
  belongs_to :user
end
