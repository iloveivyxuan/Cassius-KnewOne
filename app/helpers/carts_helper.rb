# encoding: utf-8
module CartsHelper
  def cart_items_count
    current_user.cart_items.size
  end

  def cart_item_max(kind)
    if kind.max_per_buy > 0
      [kind.stock, kind.max_per_buy].min
    else
      kind.stock
    end
  end
end
