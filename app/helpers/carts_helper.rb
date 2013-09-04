# encoding: utf-8
module CartsHelper
  def place_order_link
    link_to '结算', new_order_path, class: 'btn btn-large btn-success place-order', disabled: @has_stock_items.empty?
  end

  def delete_multiple_link
    link_to '删除', 'javascript:void(0)', class: 'delete-multiple disabled', disabled: true
  end

  def cart_items_count
    current_user.cart_items.size
  end
end
