class RefundBalanceLog < BalanceLog
  belongs_to :order

  def amount
    self.value_cents
  end
end
