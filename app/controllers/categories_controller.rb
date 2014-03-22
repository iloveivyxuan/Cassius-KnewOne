class CategoriesController < ApplicationController
  before_action :set_categories

  def index
    @categories = @categories.limit(12)
    @things = Thing.published.limit(12)
  end

  def all
    @categories = Category.gt(things_count: 10)
  end

  private

  def set_categories
    @categories = Category.gt(things_count: 10)
  end
end
