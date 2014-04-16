module Haven
  class CategoriesController < ApplicationController
    before_action :set_category, except: [:index]
    layout 'settings'

    def index
      @categories = Category.all
    end

    def edit

    end

    def update
      if @category.update category_params
        redirect_to edit_haven_category_path(@category)
      else
        render action: 'edit'
      end
    end

    private

    def category_params
      params.require(:category).permit!
    end

    def set_category
      @category = Category.find params[:id]
    end
  end
end
