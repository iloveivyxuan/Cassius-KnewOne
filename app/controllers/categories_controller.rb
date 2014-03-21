class CategoriesController < ApplicationController
  before_action :set_categories
  before_action :set_category, only: [:show]

  def index
  end

  def all
    @categories = Category.gt(things_count: 10)
  end

  private

  def set_categories
    @categories = Category.gt(things_count: 0)
  end

  def set_category
    @category = Category.find params[:id]
  end
end
