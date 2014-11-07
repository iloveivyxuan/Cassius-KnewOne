module Haven
  class OrdersController < Haven::ApplicationController
    layout 'settings'
    before_action :set_order, except: [:index, :stock]
    include ::AddressesHelper

    CITY_PLACEHOLDER = %w(市辖区 县)

    def index
      @orders = ::Order.unscoped

      @orders = @orders.where(pre_order: false) if params[:filtpreorder]

      @orders = @orders.bong_point_consumed if params[:filter_bong_order]

      @orders = @orders.where(state: params[:state]) if params[:state]

      if params[:find_cond].present?
        @orders = case params[:find_by]
                  when 'order_no'
                    @orders.where(:order_no => params[:find_cond])
                  when 'user_id'
                    @orders.where(:user_id => params[:find_cond])
                  when 'thing_id'
                    @orders.by_thing(Thing.find(params[:find_cond]))
                  when 'exclude_thing_id'
                    @orders.without_thing(Thing.find(params[:find_cond]))
                  when 'order_name'
                    @orders.where('address.name' => params[:find_cond])
                  else
                    @orders
                  end
      end

      @orders = @orders.where(:created_at.lte => params[:end_date]) if params[:end_date].present?
      @orders = @orders.where(:created_at.gte => params[:start_date]) if params[:start_date].present?

      @orders = @orders.desc(params[:order_by] || :created_at)

      respond_to do |format|
        format.html do
          return redirect_to haven_order_path(@orders.first) if @orders.count == 1
          @orders = @orders.page params[:page]
        end

        format.csv do
          if params[:filter] == 'bong'
            bong_ii = Thing.find "53d0bed731302d2c13b20000"
            bong_band = Thing.find "544f8b9331302d5139c60000"
            bong_battery = Thing.find "544f8b0a31302d4fd2dd0000"
            lines = [%w(订单时间 订单号 商品名 类型 数量 收件人 电话 省 市 区 详细地址 备注)]

            @orders.each do |order|
              city = CITY_PLACEHOLDER.include?(order.address.city) ? order.address.province : (order.address.city || '')
              order.order_items.each do |item|
                if [bong_ii, bong_band, bong_battery].include?(item.thing)
                  lines << [
                            order.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                            order.order_no,
                            item.thing_title,
                            item.kind_title.split(/[()（）]/).first.strip,
                            item.quantity,
                            order.address.name,
                            order.address.phone,
                            order.address.province,
                            city,
                            order.address.district,
                            order.address.street,
                            order.note
                           ]
                end
              end
            end
          else
            lines = [%w(订单编号 创建时间 订单状态 商品 总价 物流方式 物流单号 配送省 配送市 配送区/县 配送街道 配送姓名 配送手机号 用户备注 管理员备注 系统备注 用户ID 用户名 用户邮箱)]

            @orders.each do |order|
              city = CITY_PLACEHOLDER.include?(order.address.city) ? order.address.province : (order.address.city || '')


              cols = [
                      order.order_no,
                      order.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                      ::Order::STATES[order.state],
                      (order.order_items.map { |i| "{{ #{i.name} x #{i.quantity} }} " }.reduce &:+),
                      "￥#{order.total_price}",
                      ::Order::DELIVER_METHODS[order.deliver_by],
                      order.deliver_no,
                      order.address.province,
                      city,
                      order.address.district,
                      order.address.street,
                      order.address.name,
                      order.address.phone,
                      order.note,
                      order.admin_note,
                      order.system_note,
                      order.user_id,
                      order.user.name,
                      order.user.email
                     ]

              lines<< cols
            end
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
      redirect_to haven_order_path(@order)
    end

    def stock
      @things = Thing.where(stage: :dsell)
    end

    def ship
      @order.ship!(params[:order][:deliver_no], params[:order][:admin_note], params[:order][:deliver_by])
      redirect_to :back
    end

    def close
      @order.close!
      redirect_to haven_order_path(@order)
    end

    def refund
      @order.refund!
      redirect_to haven_order_path(@order)
    end

    def refund_to_balance
      @order.refund_to_balance!(BigDecimal.new(params[:price]))
      redirect_to haven_order_path(@order)
    end

    def refund_bong_point
      @order.refund_bong_point!(params[:point].to_i, current_user.id.to_s)
      # TODO: Remove in future, just for legacy order
      @order.refund_bong_point!(params[:point].to_i, current_user.id.to_s, order_sn: @order.order_no)

      redirect_to haven_order_path(@order)
    end

    def refunded_balance_to_platform
      @order.refunded_balance_to_platform!
      redirect_to haven_order_path(@order)
    end

    def generate_waybill
      @order.generate_waybill!
      redirect_to haven_order_path(@order)
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
