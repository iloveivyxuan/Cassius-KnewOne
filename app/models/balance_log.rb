class BalanceLog
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user

  field :value_cents, type: Integer
  validates :value_cents, presence: true, numericality: {greater_than: 0}

  field :note, type: String

  def value
    BigDecimal.new(self.value_cents) / 100
  end

  def value=(val)
    self.value_cents = (val * 100).to_i
  end

  def amount
    #stub
  end
end
