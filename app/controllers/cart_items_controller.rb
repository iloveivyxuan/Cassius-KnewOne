class CartItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :clear_illegal_cart_item, only: [:index]
  before_filter :current_cart_item, only: [:destroy, :update]

  def index
    @cart_items = current_user.cart_items
    @total_price = CartItem.total_price @cart_items
  end

  def create
    current_user.add_to_cart params[:cart_item]
    respond_to do |format|
      format.html {redirect_to cart_items_path}
      format.js
    end
  end

  def update
    @cart_item.quantity_increment (params[:step].to_i || 1)
    @cart_item.save
    @total_price = CartItem.total_price current_user.cart_items

    respond_to do |format|
      format.html { redirect_to cart_items_path }
      format.js
    end
  end

  def destroy
    current_user.cart_items.delete @cart_item
    respond_to do |format|
      format.html { redirect_to cart_items_path }
      format.js
    end
  end

  private

  def current_cart_item
    @cart_item ||= current_user.cart_items.find(params[:id])
  end

  def clear_illegal_cart_item
    current_user.cart_items.delete_if {|item| !item.legal?}
  end
end
