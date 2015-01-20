class AbatementCoupon < Coupon
  field :threshold_price, type: BigDecimal, default: 0
  field :price, type: BigDecimal, default: 0
  field :merchant_ids, type: Array, default: []
  field :exclude_thing_ids, type: Array, default: []
  field :include_pre_sell_things, type: Boolean, default: false

  validates :threshold_price, :price, :presence => true

  def use_condition(order)
    effective_order_item_price(order) >= self.threshold_price
  end

  def take_effect(order, code)
    order.rebates.build name: "#{self.name}", note: "优惠代码：#{code.code}", price: -self.price
  end

  def undo_effect(order)
    r = order.rebates.select { |rebate| rebate.name == "#{self.name}" && rebate.price == -self.price }.first
    order.rebates.delete r
  end

  private

  def effective_order_item_price(order)
    items = order.order_items

    if self.merchant_ids && self.merchant_ids.any?
      ids = Merchant.or({:id.in => self.merchant_ids}, {:_slugs.in => self.merchant_ids}).map { |m| m.id.to_s }
      items = items.where(:merchant_id.in => ids)
    end

    if self.exclude_thing_ids && self.exclude_thing_ids.any?
      ids = Thing.or({:id.in => self.exclude_thing_ids}, {:_slugs.in => self.exclude_thing_ids}).map { |t| t.id.to_s }
      items = items.where(:thing_id.nin => ids)
    end

    unless !!self.include_pre_sell_things
      items = items.reject { |item| item.kind.stage == :pre_order }
    end

    items.map(&:price).reduce(&:+) || 0
  end
end
