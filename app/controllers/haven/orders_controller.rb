module Haven
  class OrdersController < ApplicationController
    load_and_authorize_resource :order, class: ::Order

    def index
      @orders = @orders.send(params[:state].to_sym) if params[:state] && ::Order::STATES.include?(params[:state].to_sym)
      @orders = @orders.page params[:page]
    end

    def show
    end

    def update
      @order.update_attributes params[:order], as: :admin
      redirect_to haven_order_path(@order)
    end

    def ship
      @order.ship!(params[:order][:deliver_no], params[:order][:admin_note])
      redirect_to haven_orders_path
    end

    def close
      @order.close!
      redirect_to haven_orders_path
    end

    def refund
      @order.refund!
      redirect_to haven_orders_path
    end
  end
end
