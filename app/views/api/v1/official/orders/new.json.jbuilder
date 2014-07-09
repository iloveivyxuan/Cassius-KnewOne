json.total_price @order.total_price

json.items @order.order_items, partial: 'api/v1/official/orders/order_item', as: :item
json.rebates @order.rebates, partial: 'api/v1/official/orders/rebate', as: :rebate

json.options do
  json.addresses @addresses do |address|
    json.id address.id.to_s
    json.partial! 'api/v1/official/addresses/address', address: address
  end

  json.coupons @coupons do |coupon|
    json.id coupon.id.to_s
    json.partial! 'api/v1/official/coupons/coupon', coupon: coupon
  end
end

