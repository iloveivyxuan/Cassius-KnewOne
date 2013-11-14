# encoding: utf-8
module OrdersHelper
  def pay_link(order, css = 'btn btn-success')
    if order.can_pay?
      #link_to '立即支付', '#pay-modal', class: css, data: {toggle: 'modal'}, role: 'button'
      link_to '立即支付', alipay_order_path(order), class: css
    end
  end

  def cancel_link(order, css = 'btn')
    if order.can_cancel?
      link_to '取消订单', cancel_order_path(order),
              data: {confirm: '真的要取消这个订单么？'},
              class: css
    end
  end

  def ship_link(order)
    if order.can_ship?
      render 'haven/orders/form', order: order
    end
  end

  def close_link(order, css = 'btn btn-danger')
    if order.can_close?
      link_to '关闭订单', close_haven_order_path(order),
              data: {confirm: '确认关闭？'},
              method: 'put', class: css
    end
  end

  def refund_link(order, css = 'btn btn-danger')
    if order.can_refund?
      link_to '已退款', refund_haven_order_path(order),
              data: {confirm: '确认退款？'},
              method: 'put', class: css
    end
  end

  def return_link(order, css = 'btn btn-success')
    unless order.pending?
      link_to '返回首页', root_path, class: css
    end
  end

  def order_operations(order)
    [
        cancel_link(order),
        pay_link(order)
    ].compact.join('').html_safe
  end

  def state_text(order)
    Order::STATES[order.state]
  end

  def render_summary_state(order)
    css = case order.state
            when :confirmed, :shipped, :refunded then 'success'
            when :canceled, :closed then 'failure'
            else ''
          end
    content_tag :span, class: css do
      state_text order
    end
  end

  def address_text(order)
    content_for_address(order.address)
  end

  def contact_text(order)
    order.address.name
  end

  def deliver_method_text(order)
    Order::DELIVER_METHODS[order.deliver_by][:name]
  end

  def render_share_modal(order)
    items = order.order_items.sort {|i| i.single_price}.reverse
    item = items.first

    multi_items_str = ""
    if items.size > 1
     multi_items_str = "等#{items.size}种产品 "
    end

    str = "我刚刚在Knewone买了#{item.quantity}个#{item.thing.title}( #{thing_url item.thing} ) #{multi_items_str}！ @KnewOne "

    render 'shared/share', id: 'order_share', content: str, pic: item.thing.cover.url(:review)
  end
end
