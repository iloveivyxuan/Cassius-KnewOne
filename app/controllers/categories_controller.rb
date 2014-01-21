class CategoriesController < ApplicationController
  def index
    @categories = Category.desc(:things_count)
  end

  def show
    @category = Category.find params[:id]
    @things = @category.things.page(params[:page]).per(24)
  end
end
