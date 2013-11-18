module Haven
  class OrdersController < ApplicationController
    load_and_authorize_resource :order, class: ::Order

    def index
      @orders ||= ::Order

      @orders = @orders.where(state: params[:state]) if params[:state]
      if params[:find_by] == 'order_no'
        @orders = @orders.where(:order_no => params[:find_cond])
      elsif params[:find_by] == 'user_id'
        @orders = @orders.where(:user_id => params[:find_cond])
      end

      @orders = @orders.where(:created_at.lte => params[:end_date]) if params[:end_date].present?
      @orders = @orders.where(:created_at.gte => params[:start_date]) if params[:start_date].present?

      return redirect_to haven_order_path(@orders.first) if @orders.count == 1

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
