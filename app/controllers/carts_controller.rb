class CartsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @cart_items = user_cart
  end

  def create
    cart_item = user_cart.where(:thing => params[:cart_item][:thing],
                                :kind => params[:cart_item][:kind]).first
    if cart_item.nil?
      cart_item = current_user.cart_items.build params[:cart_item]
    else
      cart_item.quantity += params[:cart_item][:quantity].to_i
    end

    authorize! :create, cart_item
    result = cart_item.save!

    respond_to do |format|
      format.json { render :json => {:result => result} }
      format.html { redirect_to cart_path }
    end
  end

  def update
    cart_item = user_cart.find(params[:id])
    authorize! :update, cart_item
    cart_item.update_attributes item

    respond_to do |format|
      format.json { render :json => {:result => result} }
      format.html { redirect_to cart_path }
    end
  end

  def destroy
    cart_item = user_cart.find(params[:id])
    authorize! :destroy, cart_item
    cart_item.destroy

    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to cart_path }
    end
  end

  def update_multiple
    result = params[:cart_items].map do |item|
      cart_item = user_cart.find(item.delete(:id))
      authorize! :update, cart_item
      cart_item.update_attributes item
    end.reduce :|

    respond_to do |format|
      format.json { render :json => {:result => result} }
      format.html { redirect_to cart_path }
    end
  end

  private

  def user_cart
    current_user.cart_items.cart
  end
end
