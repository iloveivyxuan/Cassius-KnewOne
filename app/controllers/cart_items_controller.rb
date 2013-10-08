class CartItemsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cart_items = user_cart
  end

  def create
    kind = Thing.find(params[:cart_item][:thing]).find_kind(params[:cart_item][:kind_id])
    result = kind.put_in_cart(current_user, params[:cart_item][:quantity].to_i)

    respond_to do |format|
      format.json { render :json => {:result => result, :cart_items_count => cart_item_count} }
      format.html { redirect_to cart_items_path }
      format.js
    end
  end

  def update_batch
    params[:cart_items].map do |item|
      cart_item = user_cart.find(item.delete(:id))
      cart_item.update_attributes item
    end

    respond_to do |format|
      format.json { render :json => {:result => result} }
      format.html { redirect_to new_order_path }
    end
  end

  def increment
    current_cart_item.quantity_increment((params[:step].to_i || 1))
    current_cart_item.save

    respond_to do |format|
      format.json { render :json => {quantity: cart_item.quantity} }
      format.html { redirect_to cart_items_path }
    end
  end

  def destroy
    user_cart.delete current_cart_item

    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to cart_items_path }
    end
  end

  private

  def user_cart
    current_user.cart_items
  end

  def cart_item_count
    user_cart.count
  end

  def current_cart_item
    @cart_item ||= user_cart.find(params[:id])
  end
end
