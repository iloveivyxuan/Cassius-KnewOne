class OrdersController < ApplicationController
  before_filter :have_items_in_cart, :only => [:new, :create]
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

  def pay
    url = generate_tenpay_url :subject => 'KnewOne购物',
                              :body => "KnewOne订单号: #{@order.order_no}",
                              :total_fee => @order.total_cents,
                              :out_trade_no => @order.order_no
    redirect_to url
  end

  def cancel
    @order.cancel!
    redirect_to @order
  end

  def tenpay_notify
    if JaslTenpay::Notify.verify? params.except(*request.path_parameters.keys)
      @order.confirm_payment!(params[:transaction_id])
      render text: 'success'
    else
      render text: 'fail'
    end
  end

  def tenpay_callback
    # notify may reach earlier than callback
    if JaslTenpay::Sign.verify? params.except(*request.path_parameters.keys)
      @order.pay!(params[:transaction_id])
    end

    redirect_to @order
  end

  private

  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.empty?
  end

  def generate_tenpay_url(options)
    options = {
        :return_url => tenpay_callback_order_url(@order),
        :notify_url => tenpay_notify_order_url(@order),
        :spbill_create_ip => request.ip,
    }.merge(options)
    JaslTenpay::Service.create_interactive_mode_url(options)
  end
end
