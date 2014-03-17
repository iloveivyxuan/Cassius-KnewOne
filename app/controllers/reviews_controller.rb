# -*- coding: utf-8 -*-
class ReviewsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :review, through: :thing
  layout 'thing'
  after_action :allow_iframe_load, only: [:show]

  def index
    if params[:sort] == "created_at"
      @reviews = @thing.reviews.unscoped.desc(:created_at)
    end
    @reviews = @reviews.page params[:page]
  end

  def show
    mark_read @review
  end

  def new
  end

  def create
    @review.author = current_user
    if @review.save
      flash[:provider_sync] = params[:provider_sync]
      current_user.log_activity :new_review, @review
      redirect_to thing_review_path(@thing, @review)
    else
      flash.now[:error] = @review.errors.full_messages.first
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @review.update(review_params)
      redirect_to thing_review_path(@thing, @review)
    else
      flash.now[:error] = @review.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @review.destroy
    redirect_to thing_reviews_path(@thing)
  end

  def vote
    if params[:vote] == "true"
      @review.vote current_user, true
      current_user.log_activity :love_review, @review
    else
      @review.vote current_user, false
    end
    render :partial => 'voting', locals: {review: @review}, layout: false
  end

  private

  def review_params
    permit_attrs = [:title, :content, :score]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:review).permit permit_attrs
  end
end
