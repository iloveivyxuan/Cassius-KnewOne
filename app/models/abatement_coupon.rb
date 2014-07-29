class AbatementCoupon < Coupon
  field :threshold_price, type: BigDecimal, default: 0
  field :price, type: BigDecimal, default: 0

  validates :threshold_price, :price, :presence => true

  def use_condition(order)
    order.receivable >= self.threshold_price && !bong_inside?
  end

  def take_effect(order, code)
    order.rebates.build name: "#{self.name}", note: "优惠代码：#{code.code}", price: -self.price
  end

  def undo_effect(order)
    r = order.rebates.select { |rebate| rebate.name == "#{self.name}" && rebate.price == -self.price }.first
    order.rebates.delete r
  end

  private

  def bong
    @_bong ||= Thing.where(id: "53d0bed731302d2c13b20000").first
  end

  def bong_inside?
    order.order_items.where(thing_title: bong.title).exists?
  end
end
