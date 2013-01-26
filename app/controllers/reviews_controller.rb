class ReviewsController < ApplicationController
  before_filter :setup_thing
  load_and_authorize_resource

  def show
    @review = Review.find(params[:id]) || not_found
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new params[:review]
      .merge(author: current_user, thing: @thing)
    if @review.save
      redirect_to thing_review_path(@thing, @review)
    else
      render 'new'
    end
  end

  def edit
    @review = Review.find(params[:id])
    render 'new'
  end

  def update
    @review = Review.find(params[:id])
    @review.title = params[:review][:title]
    @review.content = params[:review][:content]
    @review.score = params[:review][:score]
    if @review.save
      redirect_to thing_review_path(@thing, @review)
    else
      flash.now[:error] = @review.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to @thing
  end

  def vote
    @review = Review.find(params[:id])
    @review.vote current_user, params[:vote] == "true"
    render "_voted", locals: {review: @review}, layout: false
  end

  private

  def setup_thing
    @thing = Thing.find(params[:thing_id]) || not_found
  end
end
