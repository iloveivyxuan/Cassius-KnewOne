class StoriesController < ApplicationController
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :story, through: :thing
  layout 'thing'
  after_action :allow_iframe_load, only: [:show, :index]

  def index
  end

  def show
  end

  def new
    authorize! :update, @thing
    @story = Story.new
  end

  def create
    authorize! :update, @thing
    @story = Story.new story_params
      .merge(author: current_user, thing: @thing)
    if @story.save
      redirect_to thing_stories_url(@thing)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @story.update(story_params)
      redirect_to thing_stories_url(@thing)
    else
      render 'new'
    end
  end

  def destroy
    @story.destroy
    redirect_to thing_stories_url(@thing)
  end

  private

  def story_params
    params.require(:story).permit(:title, :content, :occured_at)
  end
end
