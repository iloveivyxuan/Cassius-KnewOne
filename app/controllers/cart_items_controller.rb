class CartItemsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @cart_items = user_cart
  end

  def create
    cart_item = user_cart.where(:kind_id => params[:cart_item][:kind_id]).first
    if cart_item.nil?
      cart_item = current_user.cart_items.build params[:cart_item]
    else
      cart_item.quantity += params[:cart_item][:quantity].to_i
    end

    # authorize! :create, cart_item # no need to check
    result = cart_item.save

    respond_to do |format|
      format.json { render :json => {:result => result} }
      format.html { redirect_to cart_items_path }
    end
  end

  def update
    cart_item = user_cart.find(params[:id])
    cart_item.update_attributes quantity: params[:quantity]
    cart_item = cart_item.reload

    respond_to do |format|
      format.json { render :json => {quantity: cart_item.quantity,
                                     price: cart_item.price,
                                     total_price: total_price} }
      format.html { redirect_to cart_items_path }
    end
  end

  def increment
    cart_item = user_cart.find(params[:id])
    cart_item.update_attributes quantity: cart_item.quantity + (params[:step].to_i || 1)
    cart_item = cart_item.reload

    respond_to do |format|
      format.json { render :json => {quantity: cart_item.quantity,
                                     price: cart_item.price,
                                     total_price: total_price} }
      format.html { redirect_to cart_items_path }
    end
  end

  def destroy
    cart_item = user_cart.find(params[:id])
    authorize! :destroy, cart_item
    cart_item.destroy

    respond_to do |format|
      format.json { render :json => {total_price: total_price} }
      format.html { redirect_to cart_items_path }
    end
  end

  private

  def user_cart
    current_user.cart_items
  end

  def total_price
    user_cart.select(&:persisted?).map(&:price).reduce(&:+) || 0
  end
end
