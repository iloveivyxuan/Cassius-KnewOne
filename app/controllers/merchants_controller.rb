class MerchantsController < ApplicationController
  before_action :set_merchant, only: [:show, :set_description]

  def show
  end

  def set_description
    @merchant.update_attributes(description_params)
    redirect_to @merchant
  end

  private

  def set_merchant
    @merchant = Merchant.find params[:id]
  end

  def description_params
    if @merchant.role?(current_user)
      params.require(:merchant).permit(:description)
    end
  end
end
