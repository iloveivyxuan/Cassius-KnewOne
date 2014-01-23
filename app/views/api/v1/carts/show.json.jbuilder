json.total_price_unit '￥'
json.total_price CartItem.total_price(@items)
json.buyable_items @items.select(&:buyable?), partial: 'api/v1/cart_items/cart_item', as: :item
