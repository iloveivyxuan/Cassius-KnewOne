json.array! @coupons do |coupon|
  json.id coupon.id.to_s
  json.name coupon.name
  json.code coupon.code
  json.note coupon.note
  json.is_used coupon.used?
  json.expires_at coupon.expires_at
end
