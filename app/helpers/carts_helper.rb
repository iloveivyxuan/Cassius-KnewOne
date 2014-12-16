module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def deliver_tip_text(total_price)
    return '' if total_price == 0
    "* 88元及以上包运费（中通），以下需运费十元。"
  end
end
