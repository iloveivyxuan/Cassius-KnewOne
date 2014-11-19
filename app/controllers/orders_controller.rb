class OrdersController < ApplicationController
  before_action :require_signed_in, only: [:index, :show, :new, :create, :cancel, :tenpay, :alipay, :alipay_wap, :wxpay]
  before_action :have_items_in_cart, only: [:new, :create]
  load_and_authorize_resource except: [:index, :new, :create, :wxpay]
  layout 'settings', only: [:index, :show, :wxpay]
  skip_before_action :require_not_blocked
  skip_before_action :verify_authenticity_token, only: [:alipay_notify, :tenpay_notify, :alipay_wap_notify, :wxpay_notify]
  after_action :store_location, only: [:wxpay, :show]

  def index
    @orders = current_user.orders.page(params[:page]).per(3)
  end

  def show
  end

  def new
    @order = Order.build_order(current_user, (params.has_key?(:order) ? order_params : nil))
    @order.address ||= current_user.addresses.first
    @order.use_balance = true
  end

  def create
    if params[:order][:address_id] == 'new'
      address = current_user.addresses.build(order_params[:address])
      if address.save
        params[:order][:address_id] = address.id.to_s
      else
        current_user.addresses.delete(address)
        @order = Order.build_order(current_user, nil)
        render 'new'
        return
      end
    end

    @order = Order.build_order(current_user, order_params.except(:address))

    if @order.save
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

  def request_refund
    @order.request_refund! params[:reason]
    redirect_to @order
  end

  def cancel_request_refund
    @order.cancel_request_refund!
    redirect_to @order
  end

  def deliver_bill
    return redirect_to @order unless @order.shipped? or @order.confirmed?

    render layout: 'deliver_bill'
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
      if callback_params[:trade_state] == '0'
        @order.confirm_payment!(callback_params[:transaction_id], (callback_params[:total_fee].to_i/100), :tenpay, callback_params)
      else
        @order.unexpect!("财付通交易异常,交易号#{callback_params[:transaction_id]}", callback_params)
      end
    else
      @order.unexpect!("财付通交易异常,校验无效", callback_params)
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
      if callback_params[:trade_state] == '0'
        @order.confirm_payment!(callback_params[:transaction_id], (callback_params[:total_fee].to_i/100), :tenpay, callback_params)
      else
        @order.unexpect!("财付通交易异常,交易号#{callback_params[:transaction_id]}", callback_params)
      end
    else
      @order.unexpect!("财付通交易异常,校验无效", callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  def alipay
    redirect_to generate_alipay_url(@order)
  end

  def alipay_wap
    redirect_to generate_alipay_wap_url(@order)
  end

  def wxpay
    unless browser.wechat?
      head :forbidden
    end

    @order = Order.find params[:id]

    respond_to do |format|
      format.js do
        unless current_user.wechat_bind?
          return render js: "window.location = '#{user_omniauth_authorize_path(:wechat, state: request.fullpath, scope: 'snsapi_base')}';"
        end

        @params = generate_wxpay_jsapi_params(@order)
      end

      format.html do
        unless current_user.wechat_bind?
          return redirect_to user_omniauth_authorize_path(:wechat, state: request.fullpath, scope: 'snsapi_base')
        end

        @params = generate_wxpay_jsapi_params(@order)
      end
    end
  end

  def wxpay_callback
    redirect_to @order
  end

  def wxpay_notify
    r = WxPay::Result.new Hash.from_xml(request.body.read)

    if WxPay::Sign.verify? r
      @order.confirm_payment! r['transaction_id'], (r['total_fee'].to_i / 100), :wxpay, r
    else
      @order.unexpect!('微信交易异常', r)
    end

    head :no_content
  end

  def alipay_notify
    callback_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(callback_params)
      if %w(TRADE_SUCCESS TRADE_FINISHED).include?(callback_params[:trade_status])
        @order.confirm_payment!(callback_params[:trade_no], callback_params[:total_fee], :alipay, callback_params)
      else
        @order.unexpect!("支付宝交易异常,交易号#{callback_params[:trade_no]}，状态#{callback_params[:trade_status]}", callback_params)
      end

      render text: 'success'
    else
      @order.unexpect!("支付宝交易异常,校验无效", callback_params)

      render text: 'fail'
    end
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
      else
        @order.unexpect!("支付宝交易异常,交易号#{callback_params[:trade_no]}，状态#{callback_params[:trade_status]}", callback_params)
      end
    else
      @order.unexpect!("支付宝交易异常,校验无效", callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  def alipay_wap_notify
    callback_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify::Wap.verify?(callback_params) && data = Hash.from_xml(callback_params[:notify_data])['notify']
      if %w(TRADE_SUCCESS TRADE_FINISHED).include?(data['trade_status'])
        @order.confirm_payment!(data['trade_no'], data['total_fee'], :alipay_wap, callback_params)
      else
        @order.unexpect!("支付宝交易异常,交易号#{data['trade_no']}，状态#{data['trade_status']}", callback_params)
      end

      render text: 'success'
    else
      @order.unexpect!("支付宝交易异常,校验无效", callback_params)

      render text: 'fail'
    end
  end

  def alipay_wap_callback
    if @order.confirmed?
      return redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
    end

    callback_params = params.except(*request.path_parameters.keys)
    # notify may reach earlier than callback
    if Alipay::Sign.verify?(callback_params)
      if callback_params[:result] == 'success'
        @order.confirm_payment!(callback_params[:trade_no], @order.should_pay_price, :alipay_wap, callback_params)
      else
        @order.unexpect!("支付宝交易异常,交易号#{callback_params[:trade_no]}，返回失败", callback_params)
      end
    else
      @order.unexpect!("支付宝交易异常,签名无效", callback_params)
    end

    redirect_to @order, flash: {success: (@order.has_stock? ? '付款成功，我们将尽快为您发货' : '付款成功')}
  end

  private

  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.select { |item| item.legal? && item.has_enough_stock? }.empty?
  end

  def generate_wxpay_jsapi_params(order)
    result = WxPay::Service.invoke_unifiedorder body: "KnewOne购物订单: #{order.order_no}",
                                                out_trade_no: order.order_no,
                                                total_fee: (order.should_pay_price * 100).to_i,
                                                spbill_create_ip: request.ip,
                                                notify_url: wxpay_notify_order_url(order),
                                                trade_type: 'JSAPI',
                                                openid: current_user.wechat_auth.uid

    if result.success?
      params = {
        'appId' => Settings.wxpay.appid,
        'timeStamp' => Time.now.to_i.to_s,
        'nonceStr' => SecureRandom.uuid.tr('-', ''),
        'package' => "prepay_id=#{result['prepay_id']}",
        'signType' => 'MD5'
      }

      params['paySign'] = WxPay::Sign.generate(params)

      params.to_json
    else
      nil
    end
  end

  def generate_tenpay_url(order, options = {})
    options = {
        :bank_type => 'DEFAULT',
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

  def generate_alipay_wap_url(order, options = {})
    options = {
      :req_data => {
        :out_trade_no  => order.order_no,
        :subject       => "KnewOne购物订单: #{order.order_no}",
        :total_fee     => order.should_pay_price,
        :notify_url    => alipay_wap_notify_order_url(order),
        :call_back_url => alipay_wap_callback_order_url(order)
      }
    }

    token = Alipay::Service::Wap.trade_create_direct_token(options)
    Alipay::Service::Wap.auth_and_execute(request_token: token)
  end

  def body_text(order, length = 16)
    order.order_items.map { |i| "#{i.name}x#{i.quantity}, " }.reduce(&:+)[0..(length-1)]
  end

  def order_params
    params.require(:order).
        permit(:note, :address_id, :invoice_id, :auto_owning, :bong_point,
               :coupon_code_id, :use_balance, :use_sf, :buy_as_gift, :bong_delivery,
               address: [:province_code, :city_code, :district_code, :street, :name, :phone, :zip_code, :default])
  end
end
