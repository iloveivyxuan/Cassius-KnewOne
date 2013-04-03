class SuppliersController < ApplicationController
  load_and_authorize_resource

  def index
    @suppliers = Supplier.page params[:page]
  end

  def create
    Supplier.create params[:supplier]
  end

  def edit
  end

  def update
    @supplier.update_attributes(params[:supplier])
  end

  def destroy
    @supplier.destroy
  end
end
