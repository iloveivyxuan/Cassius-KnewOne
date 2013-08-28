# encoding: utf-8
module OrdersHelper
  def pay_link(order)
    if order.can_pay?
      link_to '支付', pay_order_path(order), method: 'put'
    end
  end

  def cancel_link(order)
    if order.can_cancel?
      link_to '取消', cancel_order_path(order),
              data: {confirm: '真的要取消这个订单么？'},
              method: 'put'
    end
  end

  def ship_link(order)
    if order.can_ship?
      link_to '发货', ship_haven_order_path(order),
              data: {confirm: '确认发货？'},
              method: 'put'
    end
  end

  def close_link(order)
    if order.can_close?
      link_to '关闭', close_haven_order_path(order),
              data: {confirm: '确认关闭？'},
              method: 'put'
    end
  end

  def refund_link(order)
    if order.can_refund?
      link_to '退货', refund_haven_order_path(order),
              data: {confirm: '确认退货？'},
              method: 'put'
    end
  end

  def order_operations(order)
    [
        link_to('查看', order),
        pay_link(order),
        cancel_link(order)
    ].compact.join(' | ').html_safe
  end
end
