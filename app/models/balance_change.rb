class BalanceChange
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :value, type: BigDecimal
  validates :value, presence: true, numericality: {greater_than: 0}

  field :note, type: String

  def amount
    #stub
  end
end
