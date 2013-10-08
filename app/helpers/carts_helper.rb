# encoding: utf-8
module CartsHelper
  def place_order_link
    submit_tag '结算', class: 'btn btn-large btn-success place-order', disabled: @cart_items.empty?
  end

  def cart_items_count
    current_user.cart_items.size
  end
end
