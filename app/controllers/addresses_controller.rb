class AddressesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @addresses = current_user.addresses
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
    @address = current_user.addresses.build params[:address]
    respond_to do |format|
      if @address.save
        format.html { redirect_back_or(addresses_path) }
        format.json { render json: @address, status: :created, location: @address }
        format.js { render 'show' }
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
      if @address.update_attributes(params[:address])
        format.html { redirect_back_or(addresses_path) }
        format.json { head :no_content }
        format.js { render 'show' }
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
end
