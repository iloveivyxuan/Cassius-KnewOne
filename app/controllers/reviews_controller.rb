# -*- coding: utf-8 -*-
class ReviewsController < PostsController
  load_and_authorize_resource :thing, except: [:admin]
  layout 'thing', except: [:admin]

  def admin
    @reviews = Review.page params[:page]
    render 'index'
  end

  def index
    @reviews = @thing.reviews.page(params[:page])
  end

  def show
    read_comments @review
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new params[:review]
      .merge(author: current_user, thing: @thing)
    if @review.save
      flash[:provider_sync] = params[:provider_sync]
      redirect_to thing_review_path(@thing, @review)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @review.update_attributes(params[:review])
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
    render :partial => 'voting', locals: {review: @review}, layout: false
  end
end
