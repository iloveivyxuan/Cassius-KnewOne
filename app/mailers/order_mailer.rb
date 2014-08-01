class OrderMailer < BaseMailer
  def ship(order_id)
    @order = Order.find order_id
    @user = @order.user

    mail(to: @user.email,
         subject: "KnewOne订单 #{@order.order_no} 已发货！")
  end

  def remind_payment(order_id)
    @order = Order.find order_id

    if @order.pending?
      @user = @order.user

      mail(to: @user.email,
           subject: "KnewOne订单 #{@order.order_no} 等待付款")
    end
  end
end
