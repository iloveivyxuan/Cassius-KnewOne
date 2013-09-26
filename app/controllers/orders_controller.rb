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
    # TODO: NYI
    @order.pay!('test')
    @order.confirm_payment!('test')

    redirect_to @order
  end

  def cancel
    @order.cancel!
    redirect_to @order
  end

  private
  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.empty?
  end
end
