class AdoptionsController < ApplicationController
  before_action :require_signed_in
  layout 'settings'

  def index
    @adoptions = current_user.adoptions
  end

  def create
    address = if params[:adoption][:address_id] == 'new'
                current_user.addresses.create! adoption_params[:address]
              else
                current_user.addresses.find params[:adoption][:address_id]
              end

    params[:adoption].delete :address
    params[:adoption].delete :address_id

    @adoption = Adoption.create! adoption_params.merge(user: current_user, address: address)
  end

  private

  def adoption_params
    params.require(:adoption).permit(:note, :thing, :address_id, address: [:province, :district, :street, :name, :phone, :zip_code, :default])
  end
end
