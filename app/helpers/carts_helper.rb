# encoding: utf-8
module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def deliver_tip_text(total_price)
    return '' if total_price == 0

    if (gap = 500 - total_price) > 0
      "(已含运费，您还需要再选购 <strong class=\"deliver_free_gap\">#{gap}</strong> 元的产品即可免费升级至顺丰速运)".html_safe
    else
      "(已含运费，使用顺丰速运)"
    end
  end
end
