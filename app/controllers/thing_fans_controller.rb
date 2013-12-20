class ThingFansController < ApplicationController
  before_action do
    raise ActionController::RoutingError.new('Not Found') unless user_signed_in? && current_user.staff?
    @thing = Thing.find(params[:thing_id])
  end

  def index
    @fans = @thing.local_tyrants
  end

  def create
    @thing.local_tyrants<< User.find(params[:user_id])

    redirect_to thing_thing_fans_path(@thing)
  end

  def destroy
    u = User.find params[:id]
    @thing.local_tyrants.delete u

    redirect_to thing_thing_fans_path(@thing)
  end
end
