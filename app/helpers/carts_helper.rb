module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def deliver_tip_text(total_price)
    return '' if total_price == 0
    "购物满 88 元包邮（普通快递），订单金额 88 元以下需另加 9 元运费。"
  end
end
