class GuidesController < ApplicationController
  load_and_authorize_resource

  def new
    @guide = Guide.new
  end

  def create
  end

  def show
  end
end
