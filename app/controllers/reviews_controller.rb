# -*- coding: utf-8 -*-
class ReviewsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :thing, singleton: true
  load_and_authorize_resource :review, through: :thing
  layout 'thing'
  after_action :allow_iframe_load, only: [:show]

  def index
    if params[:sort] == "created_at"
      @reviews = @thing.reviews.desc(:created_at)
    else
      @reviews = @thing.reviews.desc(:is_top, :lovers_count, :created_at)
    end

    @reviews = @reviews.page(params[:page]).per(params[:per])

    if request.xhr?
      render 'reviews/index_xhr', layout: false
    else
      render 'reviews/index'
    end
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
      current_user.log_activity :new_review, @review, source: @review.thing
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
    current_user.log_activity :delete_review, @review, visible: false
    redirect_to thing_reviews_path(@thing)
  end

  def vote
    @review.vote(current_user, true)

    current_user.log_activity :love_review, @review, source: @review.thing

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @review} }
    end
  end

  def unvote
    @review.unvote(current_user, true)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @review} }
    end
  end

  private

  def review_params
    permit_attrs = [:title, :content, :score]
    permit_attrs.concat [:is_top, :author] if current_user.role? :editor
    params.require(:review).permit permit_attrs
  end
end
