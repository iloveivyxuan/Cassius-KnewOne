class ImpressionsController < ApplicationController
  prepend_before_action :require_signed_in
  load_resource :thing

  respond_to :json

  def show
    @impression = @thing.impressions.find_or_initialize_by(author: current_user)
    @recent_tags = current_user.recent_tags(5)
    @popular_tags = @thing.popular_tags(5)

    respond_with @impression
  end

  def update
    @impression = @thing.impressions.find_or_create_by(author: current_user)
    @impression.update(impression_params)

    respond_with @impression
  end

  private

  def impression_params
    params.require(:impression).permit(:description, :state, :score, tag_names: [])
  end
end
