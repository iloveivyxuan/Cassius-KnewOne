class AdoptionsController < ApplicationController
  before_action :require_signed_in
  layout 'settings'

  def new
    @thing = Thing.find params[:id]
    @adoptions = @thing.adoptions
    @adoption_users_size = @adoptions.map(&:user).uniq.size
  end

  def index
    @adoptions = current_user.adoptions
  end

  def create
    if params[:adoption][:address_id] == 'new'
      address = current_user.addresses.build(adoption_params[:address])
      if address.save
        params[:adoption][:address_id] = address.id.to_s
      else
        current_user.addresses.delete(address)
        @adoption = Adoption.build_adoption(current_user, nil)
        render 'new'
        return
      end
    end

    @adoption = Adoption.build_adoption(current_user, adoption_params)
    @adoption.address = current_user.addresses.find_by(id: params[:adoption][:address_id])
    @adoption.adoption_no = rand.to_s[2..11]
    @adoption.kind = @adoption.thing.kinds.first if @adoption.kind.empty?
    unless Adoption.where(thing: @adoption.thing, user: current_user).exists?
      @adoption.save!
    end
  end

  def show
    @adoption = Adoption.find params[:id]
  end

  private

  def adoption_params
    params.require(:adoption).permit(:kind, :note, :thing, :address_id, address: [:province, :district, :street, :name, :phone, :zip_code, :default])
  end
end
