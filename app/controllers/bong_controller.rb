class BongController < ApplicationController
  layout 'application'
  prepend_before_action :require_signed_in, except: :index
  before_action except: :index do
    redirect_to '/403' unless current_user.bong_bind?
  end

  def index
    if params[:from] == 'bong_app' && !user_signed_in?
      redirect_to user_omniauth_authorize_path(:bong, state: bong_path)
    end
  end

  def consume_point
    order = current_user.orders.find params[:order_id]

    if order.consume_bong_point! params[:point].to_i
      redirect_to order, flash: {success: 'bong活跃点兑换成功'}
    else
      redirect_to order, flash: {warn: 'bong活跃点兑换失败'}
    end
  end

  def available_point
    if current_user.bong_auth.access_token.present?
      @point = current_user.bong_client.current_bong_point
    else
      @point = nil
    end

    respond_to do |format|
      format.js
    end
  end
end
