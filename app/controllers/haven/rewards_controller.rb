module Haven
  class RewardsController < ApplicationController
    before_action :set_reward, only: [:edit, :update, :destroy, :award]
    layout 'settings'

    def index
      @rewards = Reward.all
    end

    def new
      @reward = Reward.new
    end

    def edit
    end

    def create
      @reward = Reward.new(reward_params)

      if @reward.save
        redirect_to haven_rewards_path
      else
        render 'new'
      end
    end

    def update
      if @reward.update(reward_params)
        redirect_to haven_rewards_path
      else
        render 'edit'
      end
    end

    def destroy
      @reward.destroy

      redirect_to haven_rewards_path
    end

    def award
      @reward.award!

      redirect_to haven_rewards_path
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_reward
      @reward = Reward.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reward_params
      params.require(:reward).permit!
    end
  end
end
