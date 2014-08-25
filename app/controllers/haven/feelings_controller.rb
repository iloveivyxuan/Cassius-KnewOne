module Haven
  class FeelingsController < Haven::ApplicationController
    layout 'settings'

    def index
      @feelings = Feeling.desc(:created_at).page params[:page]
    end
  end
end
