#encoding: utf-8
class RewardsController < ApplicationController
  def index
    @rewards = Reward.all.page params[:page]
  end

  def show
    @reward = Reward.find(params[:id])
  end
end
