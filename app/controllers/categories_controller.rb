class CategoriesController < ApplicationController
  def index
    @categories = Category.gt(things_count: 0)
  end

  def show
    @category = Category.find params[:id]
    @things = @category.things.page(params[:page]).per(24)
  end
end
