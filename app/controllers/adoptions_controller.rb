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
        @adoption = Adoption.build_order(current_user, nil)
        render 'new'
        return
      end
    end

    @adoption = Adoption.build_adoption(current_user, adoption_params)
    @adoption.address = current_user.addresses.find_by(id: params[:adoption][:address_id])
    @adoption.adoption_no = rand.to_s[2..11]
    @adoption.save!
  end

  def show
    @adoption = Adoption.find params[:id]
  end

  def one_click
    adoption = Adoption.find params[:id]
    thing = adoption.thing
    kind = thing.kinds.find(adoption.kind)
    cart_item = CartItem.new(thing: thing, kind_id: kind.id.to_s, quantity: 1)
    current_user.cart_items << cart_item
    order = Order.build_order(current_user, nil)
    order.address ||= current_user.addresses.first
    order.use_balance = true
    order.save
    redirect_to order
  end

  private

  def adoption_params
    params.require(:adoption).permit(:kind, :note, :thing, :address_id, address: [:province, :district, :street, :name, :phone, :zip_code, :default])
  end
end
