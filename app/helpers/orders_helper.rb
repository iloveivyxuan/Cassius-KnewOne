module OrdersHelper
  def pay_link(order, view = 'orders/pay')
    if order.can_pay?
      render partial: view, locals: { order: order }
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
                data: { confirm: '真的要取消这个订单么？' },
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
                data: { confirm: '确认关闭？' },
                method: :patch, class: css
      end
    end
  end

  def refund_link(order, css = 'btn btn-danger')
    if order.can_refund?
      content_tag :div, class: 'btn-group' do
        link_to '已退款', refund_haven_order_path(order),
                data: { confirm: '确认退款？' },
                method: :patch, class: css
      end
    end
  end

  def transit_link(order, css = 'btn btn-default')
    if order.can_transit?
      content_tag :div, class: 'btn-group' do
        link_to '安排出库', transit_haven_order_path(order),
                data: { confirm: '确认出库？' },
                method: :patch, class: css
      end
    end
  end

  def refunded_balance_to_platform_link(order, css = 'btn btn-danger')
    if order.can_refunded_balance_to_platform? && order.payment_method != :btc
      content_tag :div, class: 'btn-group' do
        link_to '改退款到第三方平台', refunded_balance_to_platform_haven_order_path(order),
                data: { confirm: '确认退款？' },
                method: :patch, class: css
      end
    end
  end

  def refund_to_balance_link(order)
    if order.can_refund? && order.payment_method != :btc
      render 'haven/orders/refund_to_balance', order: order
    end
  end

  def refund_bong_point_link(order)
    if order.can_refund_bong_point?
      render 'haven/orders/refund_bong_point', order: order
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

  def deliver_bill_link(order, css = 'btn btn-default')
    content_tag :div, class: 'btn-group' do
      if order.shipped? || order.confirmed?
        link_to '发货单', deliver_bill_order_path(order), class: css, target: '_blank'
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

  def share_link(order, css = 'btn btn-default')
    if current_user.auths.any?
      items = order.order_items.sort { |i| i.single_price }.reverse
      popularize_items = items.select { |i| i.thing.sharing_text.present? }

      if popularize_items.empty?
        item = items.first

        str = "#晒牛玩# 我在剁手站 @KnewOne 上入了#{item.thing.title}，感觉超级棒！钱什么的不重要，重要的是生活质量大幅提升！别说我没告诉你 →_→ #{thing_url(item.thing, refer: :order_share)}"
      else
        item = popularize_items.first

        str = item.thing.sharing_text.
          gsub('{{item}}', "#{item.kind.title}的#{item.thing.title}").
          gsub('{{url}}', thing_url(item.thing, refer: :order_share))
      end

      content_tag :div, class: 'btn-group' do
        link_to '分享', '#share_modal', id: 'share_order_btn', class: "share_btn #{css}", data: { toggle: 'modal', content: str, pic: item.thing.cover.url(:review) }
      end
    end
  end

  def request_refund_link(order, css = 'btn btn-warning')
    if order.can_request_refund?
      content_tag :div, class: 'btn-group' do
        link_to '申请退款', '#request_refund_modal', class: css, data: { toggle: 'modal' }
      end
    end
  end

  def cancel_request_refund_link(order, css = 'btn btn-warning')
    if order.can_cancel_request_refund?
      content_tag :div, class: 'btn-group' do
        link_to '取消申请退款', cancel_request_refund_order_path(order), method: :patch, class: css
      end
    end
  end

  def order_operations(order)
    [
      pay_link(order, 'orders/pay_buttons'),
      confirm_free_link(order),
      cancel_link(order),
      request_refund_link(order),
      cancel_request_refund_link(order)
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

  def payment_method_text(order)
    Order::PAYMENT_METHOD[order.payment_method]
  end

  def new_order_path_with_params(order, options = {})
    address_id = if options.has_key?(:address_id)
                   options[:address_id]
                 elsif order.address.persisted?
                   order.address.id.to_s
                 else
                   nil
                 end

    new_order_path(order: {
      coupon_code_id: (options.has_key?(:coupon_code_id) ? options[:coupon_code_id] : order.coupon_code.try(:id)),
      address_id: address_id
    })
  end

  # 付款时间
  def payment_time(order)
    payment = order.order_histories.where(from: :pending).where(to: :confirmed).first
    date_time_text(payment.created_at) if payment
  end

  def bong_point_consumable?(order)
    order.maximal_consumable_bong_point > 0
  end

  def bong_point_text
    link_to '活跃点', '#', data: {toggle: "modal", target: "#bong_point_modal"}
  end
end
