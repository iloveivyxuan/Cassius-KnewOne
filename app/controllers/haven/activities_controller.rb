module Haven
  class ActivitiesController < Haven::ApplicationController
    layout 'settings'

    def index
      @activities = Activity.visible
      if params[:types]
        @activities = @activities.where(:type.in => params[:types].keys)
      end
      @activities = @activities.page(params[:page]).per(100)
    end
  end
end
