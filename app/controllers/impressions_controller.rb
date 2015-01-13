class ImpressionsController < ApplicationController
  prepend_before_action :require_signed_in
  load_resource :thing

  respond_to :json

  def show
    @impression = @thing.impressions.find_by(author: current_user)
    respond_with @impression
  end

  def update
    @impression = @thing.impressions.find_or_create_by(author: current_user)
    @impression.update(impression_params)
    head :no_content
  end

  private

  def impression_params
    params.require(:impression).permit(:description, :state, :score, tags: [])
  end
end
