class InvestorsController < ApplicationController
  before_action do
    raise ActionController::RoutingError.new('Not Found') unless user_signed_in? && current_user.staff?
    @thing = Thing.find(params[:thing_id])
  end

  def index
    @investors = @thing.investors
  end

  def create
    investor = Investor.new(user: User.find(params[:user_id]), amount: params[:amount])
    @thing.investors << investor

    redirect_to thing_investors_path(@thing)
  end

  def destroy
    i = @thing.investors.find params[:id]
    @thing.investors.delete i
    redirect_to thing_investors_path(@thing)
  end
end
