# encoding: utf-8
class AbatementCoupon < Coupon
  field :threshold_price, type: BigDecimal, default: 100.0
  field :price, type: BigDecimal, default: 0.0

  validates :threshold_price, :price, :presence => true
  validate do
    errors.add :threshold_price, '降价金额应比阀值金额小。' if self.threshold_price <= self.price
  end

  def use_condition(order)
    order.receivable >= self.threshold_price
  end

  def take_effect(order, code)
    order.rebates.build name: "#{self.name}", note: "优惠代码：#{code.code}", price: -self.price
  end

  def undo_effect(order)
    r = order.rebates.select {|rebate| rebate.name == "#{self.name}" && rebate.price == -self.price }.first
    order.rebates.delete r
  end
end
