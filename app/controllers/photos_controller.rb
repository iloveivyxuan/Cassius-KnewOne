class PhotosController < ApplicationController
  load_and_authorize_resource

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new
    @photo.photo = params[:photo][:path].shift
    if @photo.save
      @photo = PhotoDecorator.decorate @photo
      respond_to do |format|
        format.html do
          render json: [@photo.to_jq_upload].to_json,
          content_type: 'text/html', layout: false
        end
        format.json do
          render :json => [@photo.to_jq_upload].to_json
        end
      end
    else
      render json: [{error: "custom_failure"}], status: 304
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    render json: true
  end
end
