class ReviewsController < ApplicationController
  load_and_authorize_resource :thing
  load_and_authorize_resource

  def show
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
    render 'new'
  end

  def update
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
    @review.destroy
    redirect_to @thing
  end

  def vote
    @review.vote current_user, params[:vote] == "true"
    render "_voted", locals: {review: @review}, layout: false
  end

end
