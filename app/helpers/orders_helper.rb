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

  def ship_link(order, css = 'btn btn-warning')
    if order.can_ship?
      link_to '发货', ship_haven_order_path(order),
              data: {confirm: '确认发货？'},
              method: 'put', class: css
    end
  end

  def close_link(order, css = 'btn btn-danger')
    if order.can_close?
      link_to '关闭订单', close_haven_order_path(order),
              data: {confirm: '确认关闭？'},
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

  def address_text(order)
    content_for_address(order.address)
  end

  def contact_text(order)
    order.address.name
  end

  def deliver_method_text(order)
    Order::DELIVER_METHODS[order.deliver_by][:name]
  end
end
