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

  def reference(prize)
    return true if prize.name == "产品"
    prize.reference_id.present?
  end

  def pagination_array
    Kaminari.paginate_array(Prize.distinct(:since)).page(params[:page]).per(5)
  end

  def list_link
    link_to "KnewOne 商店产品", "lists/549d33a331302d7afb030000", target: '_blank'
  end

  def select_params
    [
     %w(分享产品最多 most_things),
     %w(产品赞数最多 most_fancied_things),
     %w(撰写评测最多 most_reviews),
     %w(评测赞数最多 most_fancied_reviews),
     %w(创建列表最多 most_thing_lists),
     %w(列表赞数最多 most_fancied_thing_lists)
    ]
  end

end
