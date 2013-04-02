class SuppliersController < ApplicationController
  load_and_authorize_resource

  def index
    @suppliers = Supplier.all
  end

  def create
    Supplier.create params[:supplier]
    render nothing: true
  end
end
