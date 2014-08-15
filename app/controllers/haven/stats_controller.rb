module Haven
  class StatsController < ApplicationController
    layout 'settings'

    def index
    end

    def new
    end

    def create
    end

    private

    def stat_params
      params.require(:stat).permit(Stat::DATAS.keys + [:date_from, :date_to, :note])
    end

  end
end
