class ImpressionsController < ApplicationController
  prepend_before_action :require_signed_in
  before_action :fix_tag_names
  load_resource :thing

  respond_to :json, :js

  def show
    @impression = @thing.impressions.find_or_initialize_by(author: current_user)
    @recent_tags = current_user.recent_tags(5)
    @popular_tags = @thing.popular_tags(5)

    respond_with @impression
  end

  def update
    @impression = @thing.impressions.find_or_initialize_by(author: current_user)
    @impression.update(impression_params)

    respond_with @impression
  end

  def destroy
    @impression = @thing.impressions.find_by(author: current_user)
    @impression.destroy

    respond_with @impression
  end

  private

  def impression_params
    params.require(:impression).permit(:fancied, :state, :description, :score, tag_names: [])
  end

  def fix_tag_names
    if params[:impression] && params[:impression].has_key?(:tag_names)
      params[:impression][:tag_names] = params[:impression][:tag_names].to_s.split(';')
    end
  end
end
