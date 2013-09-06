# encoding: utf-8
module OrdersHelper
  def pay_link(order, css = 'btn btn-large btn-success')
    if order.can_pay?
      link_to '立即支付', pay_order_path(order), method: 'put', class: css
    end
  end

  def cancel_link(order, css = 'btn btn-large')
    if order.can_cancel?
      link_to '取消订单', cancel_order_path(order),
              data: {confirm: '真的要取消这个订单么？'},
              method: 'put', class: css
    end
  end

  def ship_link(order, css = 'btn')
    if order.can_ship?
      link_to '发货', ship_haven_order_path(order),
              data: {confirm: '确认发货？'},
              method: 'put', class: css
    end
  end

  def close_link(order, css = 'btn')
    if order.can_close?
      link_to '关闭', close_haven_order_path(order),
              data: {confirm: '确认关闭？'},
              method: 'put', class: css
    end
  end

  def order_operations(order)
    [
        cancel_link(order),
        pay_link(order)
    ].compact.join('').html_safe
  end
end
