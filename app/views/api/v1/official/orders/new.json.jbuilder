json.total_price @order.total_price

json.items @order.order_items, partial: 'api/v1/official/orders/order_item', as: :item
json.rebates @order.rebates, partial: 'api/v1/official/orders/rebate', as: :rebate
