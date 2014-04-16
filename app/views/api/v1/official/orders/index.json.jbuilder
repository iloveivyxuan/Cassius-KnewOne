json.array! @orders do |order|
  json.id order.id.to_s
  json.url url_wrapper(order)
  json.html_url order_path(order)
  json.order_no order.order_no
  json.address do
    json.partial! 'api/v1/official/addresses/address', address: order.address
  end
  json.deliver_no order.deliver_no if order.deliver_no.present?
  json.trade_no order.trade_no if order.trade_no.present?
  json.deliver_by_text deliver_by_text(order)
  json.deliver_by order.deliver_by
  json.state_text state_text(order)
  json.state order.state
  json.created_at order.created_at
  json.alteration order.alteration if order.alteration.present?
  json.note order.note if order.note.present?

  json.expense_balance order.expense_balance if order.expense_balance > 0
  json.deliver_price order.deliver_price if order.deliver_price > 0
  json.total_price order.total_price
  json.should_pay_price order.should_pay_price

  json.items order.order_items, partial: 'api/v1/official/orders/order_item', as: :item
  json.rebates order.rebates, partial: 'api/v1/official/orders/rebate', as: :rebate
end
