class OrdersController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :show, :new, :create, :cancel, :tenpay, :alipay]
  before_filter :have_items_in_cart, only: [:new, :create]
  before_filter :store_location, only: [:new]
  load_and_authorize_resource except: :index

  def index
    @orders = current_user.orders
  end

  def show
  end

  def new
    @order = Order.build_order(current_user)
    @order.address = current_user.addresses.first
    @order.deliver_by = :sf
  end

  def create
    @order = Order.build_order(current_user, params[:order])
    if @order.save!
      redirect_to @order
    else
      render 'new'
    end
  end

  def cancel
    @order.cancel!
    redirect_to @order
  end

  def tenpay
    redirect_to generate_tenpay_url(@order)
  end

  def tenpay_notify
    callback_params = params.except(*request.path_parameters.keys)
    if JaslTenpay::Notify.verify?(callback_params)
      @order.confirm_payment!(callback_params[:transaction_id], :tenpay, callback_params)
      render text: 'success'
    else
      @order.cancel!(callback_params)
      render text: 'fail'
    end
  end

  def tenpay_callback
    callback_params = params.except(*request.path_parameters.keys)
    # notify may reach earlier than callback
    if JaslTenpay::Sign.verify?(callback_params)
      @order.pay!(callback_params[:transaction_id], :tenpay, callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  def alipay
    redirect_to generate_alipay_url(@order)
  end

  def alipay_notify
    callback_params = params.except(*request.path_parameters.keys)
    if Alipay::Sign.verify?(callback_params) && Alipay::Notify.verify?(callback_params)
      if %w(TRADE_SUCCESS TRADE_FINISHED).include?(callback_params[:trade_status])
        @order.confirm_payment!(callback_params[:trade_no], :alipay, callback_params)
      elsif callback_params[:trade_status] == 'TRADE_CLOSED'
        @order.cancel!(callback_params)
      end

      render text: 'success'
    else
      render text: 'fail'
    end
  end

  def alipay_callback
    callback_params = params.except(*request.path_parameters.keys)
    # notify may reach earlier than callback
    if Alipay::Sign.verify?(callback_params) && params[:trade_status] == 'TRADE_SUCCESS'
      @order.pay!(callback_params[:trade_no], :alipay, callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  private

  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.select {|item| item.legal? && item.has_enough_stock?}.empty?
  end

  def generate_tenpay_url(order, options = {})
    options = {
        :subject => 'KnewOne购物',
        :body => "KnewOne购物订单号: #{order.order_no}",
        :total_fee => order.total_cents,
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
        :subject => 'KnewOne购物',
        :body => "KnewOne购物订单号: #{order.order_no}",
        :payment_type => '1',
        :total_fee => order.total_price,
        :logistics_payment => 'SELLER_PAY',
        :return_url => alipay_callback_order_url(order),
        :notify_url => alipay_notify_order_url(order)
    }.merge(options)

    Alipay::Service.create_direct_pay_by_user_url(options)
  end
end
