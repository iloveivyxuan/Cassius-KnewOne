# -*- coding: utf-8 -*-
class ReviewPhotosController < ApplicationController
  load_and_authorize_resource

  def create
    photo = ReviewPhoto.create(image: params[:file])
    render json: photo.to_json
  end
end
