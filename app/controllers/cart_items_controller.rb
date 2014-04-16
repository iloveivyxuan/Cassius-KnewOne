class CartItemsController < ApplicationController
  before_action :require_signed_in
  before_action :current_cart_item, only: [:destroy, :update]

  def index
    current_user.cart_items.delete_if {|item| !item.legal?}
    @cart_items = current_user.cart_items
    @total_price = CartItem.total_price @cart_items
  end

  def create
    @result = current_user.add_to_cart params[:cart_item]
    respond_to do |format|
      format.html {redirect_to cart_items__url}
      format.js
    end
  end

  def update
    @cart_item.quantity_increment (params[:step].to_i || 1)
    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to cart_items__url }
        format.js { @total_price = CartItem.total_price current_user.cart_items }
      else
        format.html { redirect_to cart_items__url }
        format.js { render nothing: true }
      end
    end
  end

  def destroy
    current_user.cart_items.delete @cart_item
    @total_price = CartItem.total_price current_user.cart_items
    respond_to do |format|
      format.html { redirect_to cart_items__url }
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
