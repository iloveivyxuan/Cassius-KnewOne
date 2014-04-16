module Hell
  class ActivitiesController < ApplicationController
    def index
      @activities = Activity.visible

      if params[:started_at].to_i > 0
        @activities = @activities.gte(created_at: params[:started_at].to_i)
      end

      if params[:ended_at].to_i > 0
        @activities = @activities.lte(created_at: params[:ended_at].to_i)
      end

      if params[:types].present? && types = params[:types].split(',').compact.map(&:to_sym)
        @activities = @activities.in(type: types)
      end

      if params[:order_by] == 'desc'
        @activities = @activities.desc(:created_at)
      else
        @activities = @activities.asc(:created_at)
      end

      @activities = @activities.page(params[:page]).per(params[:per_page] || 24)
    end
  end
end
