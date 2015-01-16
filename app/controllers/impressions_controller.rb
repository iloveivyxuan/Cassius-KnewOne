class ImpressionsController < ApplicationController
  prepend_before_action :require_signed_in
  load_resource :thing

  def show
    @impression = @thing.impressions.find_by(author: current_user)
    @recent_tags = current_user.recent_tags(5)
    @popular_tags = @thing.popular_tags(5)

    respond_to do |format|
      format.json
    end
  end

  def update
    @impression = @thing.impressions.find_or_create_by(author: current_user)
    @impression.update(impression_params)
    head :no_content
  end

  private

  def impression_params
    params.require(:impression).permit(:description, :state, :score, tag_names: [])
  end
end
