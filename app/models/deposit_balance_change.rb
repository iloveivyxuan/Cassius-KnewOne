class DepositBalanceChange < BalanceChange
  def amount
    self.value
  end
end
