# encoding: utf-8
class ThingRebateCoupon < Coupon
  field :thing_id, type: String
  field :price, type: BigDecimal, default: 0

  validates :price, :presence => true
  validate do
    begin
      thing
    rescue Exception
      errors.add :thing_id, '未找到此商品'
    end
  end

  after_validation do
    self.thing_id = thing.id.to_s
  end

  def thing
    @thing ||= Thing.find(self.thing_id)
  end

  def use_condition(order)
    order.order_items.select {|item| item.thing == thing}.any?
  end

  def take_effect(order, code)
    order.rebates.build name: "#{self.name}", note: "优惠代码：#{code.code}", price: -self.price
  end

  def undo_effect(order)
    r = order.rebates.select { |rebate| rebate.name == "#{self.name}" && rebate.price == -self.price }.first
    order.rebates.delete r
  end
end
