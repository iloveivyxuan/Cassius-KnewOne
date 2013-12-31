# encoding: utf-8
module CartsHelper
  def cart_items_count
    count = current_user.cart_items.size
    (count > 0) ? count : ""
  end
end
