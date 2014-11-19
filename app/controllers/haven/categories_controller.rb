module Haven
  class CategoriesController < Haven::ApplicationController
    before_action :set_category, except: [:index, :new, :create]
    layout 'settings'

    def index
      @categories = Category.prior
    end

    def new
    end

    def create
      c = Category.new category_params
      if c.save
        redirect_to haven_categories_path
      else
        redirect_to :back
      end
    end

    def edit

    end

    def update
      if @category.update category_params
        redirect_to haven_categories_path
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
