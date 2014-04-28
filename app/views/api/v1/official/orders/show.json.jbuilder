json.id @order.id.to_s
json.html_url order_path(@order)
json.order_no @order.order_no
json.address do
  json.partial! 'api/v1/official/addresses/address', address: @order.address
end
json.deliver_no @order.deliver_no
json.trade_no @order.trade_no
json.deliver_by_text deliver_by_text(@order)
json.deliver_by @order.deliver_by
json.state_text state_text(@order)
json.state @order.state
json.created_at @order.created_at
json.alteration @order.alteration
json.note @order.note

json.expense_balance @order.expense_balance
json.deliver_price @order.deliver_price
json.total_price @order.total_price
json.should_pay_price @order.should_pay_price

json.items @order.order_items, partial: 'api/v1/official/orders/order_item', as: :item
json.rebates @order.rebates, partial: 'api/v1/official/orders/rebate', as: :rebate
