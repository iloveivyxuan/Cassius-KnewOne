# -*- coding: utf-8 -*-
class PhotosController < ApplicationController
  respond_to :json
  load_and_authorize_resource
  skip_after_action :store_location

  def show
    respond_with Photo.find(params[:id]).to_jq_upload
  end

  def create
    photo = Photo.new photo_params
    photo.user = current_user
    if photo.save
      respond_to do |format|
        format.html {
          render json: photo.to_jq_upload,
          content_type: 'text/html',
          layout: false
        }
        format.json {
          render json: photo.to_jq_upload
        }
      end
    else
      respond_with photo
    end
  end

  def destroy
    photo = Photo.find(params[:id])
    respond_with photo && photo.destroy
  end

  private

  def photo_params
    params.require(:photo).permit(:name, :size, :image)
  end
end
