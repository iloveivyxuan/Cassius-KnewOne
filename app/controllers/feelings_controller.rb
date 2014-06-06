class FeelingsController < ApplicationController
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :feeling, through: :thing
  layout 'thing'

  def index
    @feelings = if params[:sort] == "created_at"
                 @thing.feelings.desc(:created_at)
               else
                 @thing.feelings.desc(:lovers_count, :created_at)
               end.page(params[:page]).per(params[:per])

    if request.xhr?
      render 'feelings/index_xhr', layout: false
    else
      render 'feelings/index'
    end
  end

  def show
  end

  def create
    @feeling.author = current_user
    @feeling.content.gsub! /\r\n/, "\n"

    if @feeling.save
      current_user.log_activity :new_feeling, @feeling, source: @feeling.thing
      respond_to do |format|
        format.js
      end
    else
      head :request_entity_too_large
    end
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

    current_user.log_activity :delete_feeling, @feeling, visible: false

    respond_to do |format|
      format.js
    end
  end

  def vote
    @feeling.vote(current_user, true)

    current_user.log_activity :love_feeling, @feeling, source: @feeling.thing

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @feeling} }
    end
  end

  def unvote
    @feeling.unvote(current_user, true)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @feeling} }
    end
  end

  private

  def feeling_params
    params.require(:feeling).permit(:content, :score, photo_ids: [])
  end
end
