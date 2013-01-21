class ReviewsController < ApplicationController
  respond_to :json
  before_filter :setup_thing
  load_and_authorize_resource

  def index
    @reviews = @thing.reviews
    respond_with @thing, @reviews
  end

  def show
    respond_with @thing, @thing.reviews.find(params[:id])
  end

  def create
    @review = @thing.reviews.create(params[:review].merge(author: current_user))
    respond_with @thing, @review
  end

  def update
    @review = @thing.reviews.find params[:id]
    @review.update_attributes(params[:review])
    respond_with @thing, @review
  end

  def destroy
    review = @thing.reviews.find params[:id]
    respond_with @thing, @thing.reviews.delete(review)
  end

  private

  def setup_thing
    @thing = Thing.find(params[:thing_id]) || not_found
  end
end
