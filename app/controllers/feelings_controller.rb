class FeelingsController < ApplicationController
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :feeling, through: :thing
  layout 'thing'

  def index
    @feelings = if params[:sort] == "created_at"
                  @thing.feelings.unscoped.desc(:created_at)
                else
                  @thing.feelings
                end.page params[:page]
  end

  def show
  end

  def new
  end

  def create
    @feeling.author = current_user
    @feeling.save

    respond_to do |format|
      format.js
    end
  end

  def edit
    render 'new'
  end

  def update
    if @feeling.update(feeling_params)
      redirect_to thing_feeling_path(@thing, @feeling)
    else
      flash.now[:error] = @feeling.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @feeling.destroy
    redirect_to thing_feelings_path(@thing)
  end

  def vote
    if params[:vote] == "true"
      @feeling.vote current_user, true
    else
      @feeling.vote current_user, false
    end
    render partial: 'voting', locals: {feeling: @feeling}, layout: false
  end

  private

  def feeling_params
    permit_attrs = [:content, :score, :photo_ids]
    params.require(:feeling).permit permit_attrs
  end
end
