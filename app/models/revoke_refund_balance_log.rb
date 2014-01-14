class RevokeRefundBalanceLog < BalanceLog
  belongs_to :order

  def amount
    -self.value_cents
  end
end
