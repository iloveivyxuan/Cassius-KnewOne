class RewardsController < ApplicationController
  def index
    @rewards = Reward.awarded.page params[:page]
  end
end
