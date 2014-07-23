module Haven
  class FeelingsController < ApplicationController
    layout 'settings'

    def index
      @feelings = Feeling.desc(:created_at).page params[:page]
    end
  end
end
