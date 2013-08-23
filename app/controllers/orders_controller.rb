class OrdersController < ApplicationController
  before_filter :have_items_in_cart, :only => [:new, :create]
  load_and_authorize_resource

  def index
  end

  def show
  end

  def new
    @order = Order.place_order(current_user)
    @order.address = current_user.addresses.first
  end

  def create
    @order = Order.place_order(current_user, params[:order])
    if @order.save!
      redirect_to orders_path
    else
      render 'new'
    end
  end

  def pay
  end

  def cancel
    @order.cancel!
    redirect_to orders_path
  end

  private
  def have_items_in_cart
    redirect_to root_path if current_user.cart_items.empty?
  end
end
