module Haven
  class StatsController < ApplicationController
    layout 'settings'

    def index
      if params["date"]
        @date_from = Date.new(params["date"]["from(1i)"].to_i, params["date"]["from(2i)"].to_i, params["date"]["from(3i)"].to_i)
        @date_to = Date.new(params["date"]["to(1i)"].to_i, params["date"]["to(2i)"].to_i, params["date"]["to(3i)"].to_i)
      end

      case params["shortcut"]
      when "yesterday"
        @date_from = @date_to = 1.day.ago.to_date
      when "last_week"
        @date_from = Date.today.last_week.beginning_of_week.to_date
        @date_to = Date.today.last_week.end_of_week.to_date
      when "last_month"
        @date_from = 1.month.ago.beginning_of_month.to_date
        @date_to = 1.month.ago.end_of_month.to_date
      end

      if @date_from && @date_to
        @new_users = User.where(:created_at.gte => @date_from).where(:created_at.lte => @date_to.next_day).all.size
        @new_things = Activity.by_type(:new_thing).from_date(@date_from).to_date(@date_to).all.size
        @new_reviews = Activity.by_type(:new_review).from_date(@date_from).to_date(@date_to).all.size
        @new_feelings = Activity.by_type(:new_feeling).from_date(@date_from).to_date(@date_to).all.size
        login_activities = Activity.by_type(:login_user).from_date(@date_from).to_date(@date_to).all
        unless login_activities
          @login_times = login_activities.size
          @login_users = login_activities.map(&:user).uniq!.size
        end
        comments = Activity.by_type(:comment).from_date(@date_from).to_date(@date_to)
        @review_comments = comments.select { |a| a.reference.class == Review }.size
        @feeling_comments = comments.select { |a| a.reference.class == Feeling }.size
      end
    end

  end
end
