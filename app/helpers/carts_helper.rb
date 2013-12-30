# encoding: utf-8
module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end

  def max_buyable_quantity(kind)
    if kind.max_per_buy.present? and kind.max_per_buy > 0
      [kind.stock, kind.max_per_buy].min
    else
      kind.stock
    end
  end
end
