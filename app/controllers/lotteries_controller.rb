class LotteriesController < ApplicationController
  load_and_authorize_resource

  def index
    @lotteries = Lottery.page params[:page]
  end

  def new
    @lottery.contribution_link = params[:contribution_link]
  end

  def create
     @lottery = Lottery.new params[:lottery]
    if @lottery.save
      redirect_to lotteries_path
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @lottery.update_attributes(params[:lottery])
      redirect_to lotteries_path
    else
      render 'new'
    end
  end

  def destroy
    @lottery.destroy
    redirect_to lotteries_path
  end
end
