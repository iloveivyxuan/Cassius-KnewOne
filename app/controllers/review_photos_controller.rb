class ReviewPhotosController < ApplicationController
  load_and_authorize_resource

  def create
    photo = ReviewPhoto.create(image: params[:file])
    respond_to do |format|
      format.json {render json: photo.to_json}
    end
  end

end
