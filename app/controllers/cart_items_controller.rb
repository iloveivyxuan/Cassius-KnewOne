class CartItemsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @has_stock_items = user_cart.select(&:has_stock?)
    @out_stock_items = (user_cart - @has_stock_items)#.each &:destroy
  end

  def create
    cart_item = user_cart.where(:kind_id => params[:cart_item][:kind_id]).first
    if cart_item.nil?
      cart_item = current_user.cart_items.build params[:cart_item]
    else
      cart_item.quantity += params[:cart_item][:quantity].to_i
      cart_item.quantity = cart_item.kind.stock unless cart_item.has_stock?
    end

    result = cart_item.save

    respond_to do |format|
      format.json { render :json => {:result => result, :cart_items_count => cart_item_count} }
      format.html { redirect_to cart_items_path }
    end
  end

  def update
    cart_item = user_cart.find(params[:id])
    cart_item.quantity = params[:quantity]
    cart_item.quantity = cart_item.kind.stock unless cart_item.has_stock?
    cart_item.save

    respond_to do |format|
      format.json { render :json => {quantity: cart_item.quantity,
                                     price: cart_item.price,
                                     total_price: total_price,
                                     cart_items_count: cart_item_count} }
      format.html { redirect_to cart_items_path }
    end
  end

  def increment
    cart_item = user_cart.find(params[:id])
    cart_item.quantity = cart_item.quantity + (params[:step].to_i || 1)
    cart_item.quantity = cart_item.kind.stock unless cart_item.has_stock?
    cart_item.save

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
      format.json { render :json => {total_price: total_price,
                                     cart_items_count: cart_item_count} }
      format.html { redirect_to cart_items_path }
    end
  end

  private

  def user_cart
    current_user.cart_items
  end

  def cart_item_count
    user_cart.select(&:persisted?).count
  end

  def total_price
    user_cart.select(&:persisted?).map(&:price).reduce(&:+) || 0
  end
end
