module Haven
  class StatsController < Haven::ApplicationController
    layout 'settings'

    def index
      @stat = Stat.where(:status => :day).last
    end

    def update
      stat = Stat.find params[:id]
      stat.update(stat_params)
      redirect_to haven_stats_path
    end

    def edit
      @stat = Stat.where(date_from: params[:query], status: params[:status]).first
    end

    private

    def stat_params
      params.require(:stat).permit(Stat::DATAS.keys + [:date_from, :date_to, :status])
    end
  end
end
