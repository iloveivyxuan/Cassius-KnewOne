class DepositBalanceLog < BalanceLog
  def amount
    self.value_cents
  end
end
