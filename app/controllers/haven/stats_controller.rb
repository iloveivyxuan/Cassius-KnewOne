module Haven
  class StatsController < ApplicationController
    layout 'settings'

    def index
    end

    def new
      @date_from = Date.new(params["date"]["from(1i)"].to_i, params["date"]["from(2i)"].to_i, params["date"]["from(3i)"].to_i)
      @date_to = Date.new(params["date"]["to(1i)"].to_i, params["date"]["to(2i)"].to_i, params["date"]["to(3i)"].to_i)
      @stat = Stat.generate_stats(Stat.new, @date_from, @date_to)
    end

    def create
      group = Group.find("53ed7b6b31302d5e7b9d0900")
      @stat = Stat.create stat_params
      topic = @stat.to_topic(current_user, group)
      redirect_to group_topic_url(group, topic)
    end

    private

    def stat_params
      params.require(:stat).permit(Stat::DATAS.keys + [:date_from, :date_to, :note])
    end

  end
end
