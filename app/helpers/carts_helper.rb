module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def deliver_tip_text(total_price)
    return '' if total_price == 0
    "*总价已含运费(普通快递)，bong 系列产品需要收取额外运费，统一发圆通快递。"
  end
end
