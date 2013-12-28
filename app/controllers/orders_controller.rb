# -*- coding: utf-8 -*-
class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :new, :create, :cancel, :tenpay, :alipay]
  before_action :have_items_in_cart, only: [:new, :create]
  load_and_authorize_resource except: [:index, :new, :create], params: :order_params
  layout 'settings', only: [:index, :show]

  def index
    @orders = current_user.orders
  end

  def show
  end

  def new
    @order = Order.build_order(current_user, (params.has_key?(:order) ? order_params : nil))
    @order.address ||= current_user.addresses.first
    @order.deliver_by ||= :sf
  end

  def create
    @order = Order.build_order(current_user, order_params)
    if @order.save!
      redirect_to @order, flash: {provider_sync: params[:provider_sync]}
    else
      render 'new'
    end
  end

  def cancel
    @order.cancel!
    redirect_to @order
  end

  def confirm_free
    @order.confirm_free!
    redirect_to @order
  end

  def tenpay
    redirect_to generate_tenpay_url(@order)
  end

  def tenpay_wechat
    redirect_to generate_tenpay_url(@order, bank_type: 'WX')
  end

  def tenpay_notify
    callback_params = params.except(*request.path_parameters.keys)
    if JaslTenpay::Notify.verify?(callback_params)
      @order.confirm_payment!(callback_params[:transaction_id], callback_params[:total_fee], :tenpay, callback_params)
    else
      @order.unexpect!("通过财付通交易异常,校验无效", callback_params)
    end

    render text: 'success'
  end

  def tenpay_callback
    if @order.confirmed?
      return redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
    end

    callback_params = params.except(*request.path_parameters.keys)
    # notify may reach earlier than callback
    if JaslTenpay::Notify.verify?(callback_params)
      @order.confirm_payment!(callback_params[:transaction_id], callback_params[:total_fee], :tenpay, callback_params)
    else
      @order.unexpect!("财付通交易异常,交易号#{callback_params[:transaction_id]}", callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  def alipay
    redirect_to generate_alipay_url(@order)
  end

  def alipay_notify
    callback_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(callback_params)
      if %w(TRADE_SUCCESS TRADE_FINISHED).include?(callback_params[:trade_status])
        @order.confirm_payment!(callback_params[:trade_no], callback_params[:total_fee], :alipay, callback_params)
      elsif callback_params[:trade_status] == 'TRADE_CLOSED'
        @order.unexpect!("支付宝交易异常,交易号#{callback_params[:trade_no]}，状态TRADE_CLOSED", callback_params)
      end
    else
      @order.unexpect!("支付宝交易异常,校验无效", callback_params)
    end

    render text: 'success'
  end

  def alipay_callback
    if @order.confirmed?
      return redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
    end

    callback_params = params.except(*request.path_parameters.keys)
    # notify may reach earlier than callback
    if Alipay::Notify.verify?(callback_params)
      if %w(TRADE_SUCCESS TRADE_FINISHED).include?(callback_params[:trade_status])
        @order.confirm_payment!(callback_params[:trade_no], callback_params[:total_fee], :alipay, callback_params)
      elsif callback_params[:trade_status] == 'TRADE_CLOSED'
        @order.unexpect!("支付宝交易异常,交易号#{callback_params[:trade_no]}，状态TRADE_CLOSED", callback_params)
      end
    else
      @order.unexpect!("支付宝交易异常,校验无效", callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  private

  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.select { |item| item.legal? && item.has_enough_stock? }.empty?
  end

  def generate_tenpay_url(order, options = {})
    options = {
        :subject => "KnewOne购物订单: #{order.order_no}",
        :body => body_text(order, 16),
        :total_fee => (order.should_pay_price * 100).to_i,
        :out_trade_no => order.order_no,
        :return_url => tenpay_callback_order_url(order),
        :notify_url => tenpay_notify_order_url(order),
        :spbill_create_ip => request.ip,
    }.merge(options)

    JaslTenpay::Service.create_interactive_mode_url(options)
  end

  def generate_alipay_url(order, options = {})
    options = {
        :out_trade_no => order.order_no,
        :subject => "KnewOne购物订单: #{order.order_no}",
        :body => body_text(order, 500),
        :payment_type => '1',
        :total_fee => order.should_pay_price,
        :logistics_payment => 'SELLER_PAY',
        :return_url => alipay_callback_order_url(order),
        :notify_url => alipay_notify_order_url(order)
    }.merge(options)

    Alipay::Service.create_direct_pay_by_user_url(options)
  end

  def body_text(order, length = 16)
    order.order_items.map { |i| "#{i.name}x#{i.quantity}, " }.reduce(&:+)[0..(length-1)]
  end

  def order_params
    params.require(:order).
        permit(:note, :deliver_by, :address_id, :invoice_id, :auto_owning, :coupon_code_id, :use_balance)
  end
end
