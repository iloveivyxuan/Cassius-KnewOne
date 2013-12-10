# -*- coding: utf-8 -*-
class ReviewsController < ApplicationController
  include Commentable
  load_and_authorize_resource :thing, except: [:all], singleton: true
  load_and_authorize_resource :thing_group, through: :thing, except: [:all], singleton: true
  load_and_authorize_resource :review, through: :thing_group
  layout 'thing', except: [:all]

  def index
    @reviews = @reviews.page params[:page]
  end

  def show
    read_comments @review
  end

  def new
  end

  def create
    @review.author = current_user
    if @review.save
      flash[:provider_sync] = params[:provider_sync]
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
    @review.vote current_user, params[:vote] == "true"
    render :partial => 'voting', locals: {review: @review}, layout: false
  end

  def all
    @reviews = Review.unscoped.desc(:created_at).page params[:page]
    render 'all'
  end

  private

  def review_params
    permit_attrs = [:title, :content, :score]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:review).permit permit_attrs
  end
end
