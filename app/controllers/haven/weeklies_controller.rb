module Haven
  class WeekliesController < Haven::ApplicationController
    layout 'settings'
    before_action :set_weekly, except: [:index, :create, :new, :edm]

    def index
      @weeklies = Weekly.desc(:created_at).page params[:page]
    end

    def edit

    end

    def new
      @weekly = Weekly.new
    end

    def update
      @weekly.update_attributes weekly_params

      redirect_to haven_weeklies_url
    end

    def create
      @weekly = Weekly.new weekly_params

      if @weekly.save
        redirect_to haven_weeklies_url
      else
        render 'new'
      end
    end

    def destroy
      @weekly.destroy

      redirect_to haven_weeklies_url
    end

    def deliver
      UserMailer.weekly(@weekly, current_user).deliver_now

      redirect_to haven_weeklies_url
    end

    def edm
      Weekly.delay.send_edm_to_users! params[:id]

      redirect_to haven_weeklies_url
    end

    private

    def weekly_params
      params.require(:weekly).permit!
    end

    def set_weekly
      @weekly = Weekly.find(params[:id])
    end
  end
end
