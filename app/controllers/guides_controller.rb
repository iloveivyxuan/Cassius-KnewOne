class GuidesController < ApplicationController
  load_and_authorize_resource

  def new
    @guide = Guide.new
    @guide.steps.build(title: "Intro", content: "Hello")
  end

  def create
    @guide = Guide.new params[:guide].merge(author: current_user)
    if @guide.save
      redirect_to @guide
    else
      render 'new'
    end
  end

  def show
    @guide = Guide.find(params[:id])
  end

  def edit
    @guide = Guide.find(params[:id])
    render 'new'
  end

  def update
    @guide = Guide.find(params[:id])
    if @guide.update_attributes(params[:guide])
      redirect_to @guide
    else
      render 'new'
    end
  end
end
