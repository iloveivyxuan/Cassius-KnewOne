module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def deliver_tip_text(total_price)
    return '' if total_price == 0

    if (gap = 500 - total_price) > 0
      "*总价已含运费(中通快递)，再选购 <strong class=\"deliver_free_gap\">#{gap}</strong> 元的产品即可免费升级至顺丰速运(或补10元)。".html_safe
    else
      '*总价已含运费(顺丰速运)。'
    end
  end
end
