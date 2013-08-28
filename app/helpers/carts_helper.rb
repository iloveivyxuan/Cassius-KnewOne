# encoding: utf-8
module CartsHelper
  def order_link
    link_to '结算', new_order_path unless @cart_items.empty?
  end
end
