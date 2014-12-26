module PrizesHelper

  def coupon_link(coupon)
    return unless coupon
    if coupon.is_a?(ThingRebateCoupon)
      link_to coupon.thing.title, coupon.thing
    else
      coupon.name
    end
  end

  def coupon_amount(coupon)
    if coupon.is_a?(ThingRebateCoupon)
      "一个。"
    else
      "一张。"
    end
  end

  def thing_coupon_url(things)
    thing = things.ne(coupon_code_id: nil).map(&:coupon)
      .select { |c| c.is_a?(ThingRebateCoupon) }
      .map(&:thing)
      .sort_by(&:fanciers_count).reverse.first

    thing.photos.first.url(:square) if thing
  end

end
