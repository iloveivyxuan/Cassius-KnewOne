# encoding: utf-8
module CartsHelper
  def place_order_link

  end

  def cart_items_count
    current_user.cart_items.size
  end
end
