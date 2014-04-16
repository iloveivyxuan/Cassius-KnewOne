#encoding: utf-8

module Haven
  class OrdersController < ApplicationController
    layout 'settings'
    before_action :set_order, except: :index
    include ::AddressesHelper

    def index
      @orders = ::Order.unscoped

      @orders = @orders.where(state: params[:state]) if params[:state]
      if params[:find_by] == 'order_no'
        @orders = @orders.where(:order_no => params[:find_cond])
      elsif params[:find_by] == 'user_id'
        @orders = @orders.where(:user_id => params[:find_cond])
      end

      @orders = @orders.where(:created_at.lte => params[:end_date]) if params[:end_date].present?
      @orders = @orders.where(:created_at.gte => params[:start_date]) if params[:start_date].present?

      @orders = @orders.desc(:updated_at)

      respond_to do |format|
        format.html do
          return redirect_to haven_order_url(@orders.first) if @orders.count == 1

          @orders = @orders.page params[:page]
        end

        format.csv do
          lines = [%w(订单编号 创建时间 订单状态 商品 总价 物流方式 物流单号 配送地址 用户备注 管理员备注 系统备注 用户ID 用户名 用户邮箱)]

          @orders.each do |order|
            cols = [
                order.order_no,
                order.created_at.strftime('%Y-%m-%d'),
                ::Order::STATES[order.state],
                (order.order_items.map { |i| "{{ #{i.name} x #{i.quantity} }} " }.reduce &:+),
                "￥#{order.total_price}",
                ::Order::DELIVER_METHODS[order.deliver_by],
                order.deliver_no,
                content_for_address(order.address),
                order.note,
                order.admin_note,
                order.system_note,
                order.user_id,
                order.user.name,
                order.user.email
            ]
            lines<< cols
          end

          col_sep = (params[:platform] == 'numbers') ? ',' : ';'

          csv = CSV.generate :col_sep => col_sep do |csv|
            lines.each { |l| csv<< l }
          end

          if params[:platform] != 'numbers'
            send_data csv.encode 'gb2312', :replace => ''
          else
            send_data csv, :replace => ''
          end
        end
      end
    end

    def show
    end

    def update
      @order.update order_params
      redirect_to haven_order_url(@order)
    end

    def ship
      @order.ship!(params[:order][:deliver_no], params[:order][:admin_note])
      redirect_to haven_order_url(@order)
    end

    def close
      @order.close!
      redirect_to haven_order_url(@order)
    end

    def refund
      @order.refund!
      redirect_to haven_order_url(@order)
    end

    def refund_to_balance
      @order.refund_to_balance!(BigDecimal.new(params[:price]))
      redirect_to haven_order_url(@order)
    end

    def refunded_balance_to_platform
      @order.refunded_balance_to_platform!
      redirect_to haven_order_url(@order)
    end

    def generate_waybill
      @order.generate_waybill!
      redirect_to haven_order_url(@order)
    end

    private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit!
    end
  end
end
