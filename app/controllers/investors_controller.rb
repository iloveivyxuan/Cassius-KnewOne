class InvestorsController < ApplicationController
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource
  layout 'thing'

  def index
    @investors = @thing.investors.page params[:page]
  end

  def admin
    @investors = @thing.investors.page params[:page]
  end

  def create
    investor = Investor.new(user: User.find(params[:user_id]), amount: params[:amount])
    @thing.investors << investor

    redirect_to admin_thing_investors_path(@thing)
  end

  def destroy
    i = @thing.investors.find params[:id]
    @thing.investors.delete i
    redirect_to admin_thing_investors_path(@thing)
  end
end
