class CartItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :current_cart_item, only: [:destroy, :update]

  def index
    current_user.cart_items.delete_if {|item| !item.legal?}
    @cart_items = current_user.cart_items
    @total_price = CartItem.total_price @cart_items
  end

  def create
    @result = current_user.add_to_cart params[:cart_item]
    respond_to do |format|
      format.html {redirect_to cart_items_path}
      format.js
    end
  end

  def update
    @cart_item.quantity_increment (params[:step].to_i || 1)
    respond_to do |format|
      if @cart_item.save
        @total_price = CartItem.total_price current_user.cart_items
        format.html { redirect_to cart_items_path }
        format.js
      else
        render nothing: true
      end
    end
  end

  def destroy
    current_user.cart_items.delete @cart_item
    @total_price = CartItem.total_price current_user.cart_items
    respond_to do |format|
      format.html { redirect_to cart_items_path }
      format.js
    end
  end

  private

  def current_cart_item
    @cart_item ||= current_user.cart_items.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:thing, :quantity, :kind_id)
  end
end
