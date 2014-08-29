module Haven
  class StatsController < Haven::ApplicationController
    layout 'settings'

    def index
      if params[:query]
        @stat = Stat.find_by(date_from: params[:query], status: params[:status])
      else
        @stat = Stat.last
      end
    end

    def update
      stat = Stat.find params[:id]
      stat.update(stat_params)
      redirect_to haven_stats_path
    end

    private

    def stat_params
      params.require(:stat).permit(Stat::DATAS.keys + [:date_from, :date_to, :status])
    end
  end
end
