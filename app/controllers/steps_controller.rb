class StepsController < ApplicationController
  load_and_authorize_resource
  before_filter :setup_guide

  private

  def setup_guide
    @guide = Guide.find(params[:guide_id])
  end
end
