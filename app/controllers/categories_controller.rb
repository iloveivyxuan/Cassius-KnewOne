class CategoriesController < ApplicationController
  before_action :set_categories

  def index
    @promotion = Promotion.newest
    @categories = @categories.limit(12)
    @things = Thing.published.desc(:created_at).limit(12)
  end

  def all
    @categories = Category.desc(:things_count).gt(things_count: 10)
  end

  private

  def set_categories
    @categories = Category.desc(:things_count).gt(things_count: 10)
  end
end
