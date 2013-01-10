class PhotosController < ApplicationController
  respond_to :json
  load_and_authorize_resource

  def show
    respond_with Photo.find(params[:id])
  end

  def create
    respond_with Photo.create(params[:photo].merge(user: current_user))
  end

  def destroy
    photo = Photo.find(params[:id])
    respond_with photo && photo.destroy
  end
end
