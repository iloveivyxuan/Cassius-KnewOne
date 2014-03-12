# -*- coding: utf-8 -*-
class ReviewsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :thing, except: [:admin], singleton: true
  load_and_authorize_resource :review, through: :thing, except: [:admin]
  layout 'thing', except: [:admin]
  after_action :allow_iframe_load, only: [:show]

  def index
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

  def admin
    @reviews = Review.unscoped.desc(:created_at).page params[:page]
  end

  private

  def review_params
    permit_attrs = [:title, :content, :score]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:review).permit permit_attrs
  end
end
