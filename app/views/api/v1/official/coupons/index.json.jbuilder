json.array! @coupons do |coupon|
  json.id coupon.id.to_s
  json.partial! 'api/v1/official/coupons/coupon', coupon: coupon
end
