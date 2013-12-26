# encoding: utf-8
module OrdersHelper
  def pay_link(order, drop_up = true, css = 'btn btn-success')
    if order.can_pay?
      render partial: 'orders/pay', locals: {order: order, css: css, dropup: drop_up}
    end
  end

  def confirm_free_link(order, css = 'btn btn-success')
    if order.can_confirm_free?
      content_tag :div, class: 'btn-group' do
        link_to '确认订单', confirm_free_order_path(order),
                method: :patch, class: css
      end
    end
  end

  def cancel_link(order, css = 'btn btn-default')
    if order.can_cancel?
      content_tag :div, class: 'btn-group' do
        link_to '取消订单', cancel_order_path(order),
                data: {confirm: '真的要取消这个订单么？'},
                method: :patch, class: css
      end
    end
  end

  def ship_link(order)
    if order.can_ship?
      render 'haven/orders/ship', order: order
    end
  end

  def close_link(order, css = 'btn btn-danger')
    if order.can_close?
      content_tag :div, class: 'btn-group' do
        link_to '关闭订单', close_haven_order_path(order),
                data: {confirm: '确认关闭？'},
                method: :patch, class: css
      end
    end
  end

  def refund_link(order, css = 'btn btn-danger')
    if order.can_refund?
      content_tag :div, class: 'btn-group' do
        link_to '已退款', refund_haven_order_path(order),
                data: {confirm: '确认退款？'},
                method: :patch, class: css
      end
    end
  end

  def refund_to_balance_link(order)
    if order.can_refund?
      render 'haven/orders/refund_to_balance', order: order
    end
  end

  def way_bill_link(order, css = 'btn btn-default')
    content_tag :div, class: 'btn-group' do
      if order.waybill.url.nil?
        link_to '生成运单', generate_waybill_haven_order_path(order), class: css
      else
        link_to '下载运单', order.waybill.url, class: css, target: '_blank'
      end
    end
  end

  def return_link(order, css = 'btn btn-default')
    unless order.pending?
      content_tag :div, class: 'btn-group' do
        link_to '返回首页', root_path, class: css
      end
    end
  end

  def share_link(css = 'btn btn-default')
    if current_user.auths.any?
      content_tag :div, class: 'btn-group' do
        link_to '分享', '#order_share', class: css, data: {toggle: 'modal'}
      end
    end
  end

  def order_operations(order)
    [
        cancel_link(order),
        pay_link(order),
        confirm_free_link(order)
    ].compact.join('').html_safe
  end

  def state_text(order)
    Order::STATES[order.state]
  end

  def render_summary_state(order)
    css = case order.state
            when :confirmed, :shipped, :refunded then
              'success'
            when :canceled, :closed then
              'failure'
            else
              ''
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
    Order::DELIVER_METHODS[order.deliver_by]
  end

  def render_share_modal(order)
    items = order.order_items.sort { |i| i.single_price }.reverse
    popularize_items = items.select { |i| i.thing.sharing_text.present? }

    if popularize_items.empty?
      item = items.first

      multi_items_str = ""
      if items.size > 1
        multi_items_str = "等#{items.size}种产品 "
      end

      str = "#KnewOne晒订单# 我在剁手网站 @KnewOne 买了“#{item.thing.title} - #{item.kind.title}”（价格￥#{item.single_price}）#{multi_items_str} 瞬间变身土豪，高端大气上档次的感觉你们是不会知道的！小伙伴们要不要来围观一下？围观地址： #{thing_url item.thing}"
    else
      item = popularize_items.first

      str = item.thing.sharing_text.
          gsub('{{item}}', "“#{item.thing.title} - #{item.kind.title}”（价格￥#{item.single_price}）").
          gsub('{{url}}', thing_url(item.thing))
    end

    render 'shared/share', id: 'order_share', content: str, pic: item.thing.cover.url(:review)
  end

  def new_order_path_with_params(order, options = {})
    new_order_path(order: {
        coupon_code_id: (options.has_key?(:coupon_code_id) ? options[:coupon_code_id] : order.coupon_code.try(:id)),
        address_id: (options.has_key?(:address_id) ? options[:address_id] : order.address.try(:id))
    })
  end
end
