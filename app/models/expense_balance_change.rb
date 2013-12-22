class ExpenseBalanceChange < BalanceChange
  belongs_to :order

  def amount
    -self.value
  end
end
