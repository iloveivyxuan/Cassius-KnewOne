class AddressesController < ApplicationController
  before_action :require_signed_in
  layout 'settings'
  skip_before_action :require_not_blocked

  def index
    if current_user.role? :editor and params[:user]
      # admin can check user addresses
      @addresses = User.find(params[:user]).addresses
    else
      @addresses = current_user.addresses
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @addresses }
    end
  end

  def new
    @address = current_user.addresses.build
    respond_to do |format|
      format.html { render 'new' }
      format.json { render json: @address }
    end
  end

  def create
    @address = current_user.addresses.build address_params
    respond_to do |format|
      if @address.save
        format.html { redirect_back_or(addresses_path) }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @address = current_user.addresses.find params[:id]
  end

  def update
    @address = current_user.addresses.find params[:id]
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_back_or(addresses_path) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @address = current_user.addresses.find params[:id]
    @address.destroy
    respond_to do |format|
      format.html { redirect_to addresses_path }
      format.json { head :no_content }
    end
  end

  private

  def address_params
    params.require(:address)
      .permit(:province, :district, :street, :name, :phone, :zip_code, :default)
  end
end
