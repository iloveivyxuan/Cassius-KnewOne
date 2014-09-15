module Haven
  class TagsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_tag, only: [:edit, :update, :destroy]

    def index
      @tags = Tag.all
    end

    def new
    end

    def create
      category = Category.where(name: params[:tag][:category]).first
      tag = Tag.new(name: params[:tag][:name], category: category)
      if tag.save
        redirect_to haven_tags_path
      end
    end

    def edit
    end

    def update
      new_category = Category.where(name: tag_params.values.first).first
      @tag.category = new_category if new_category
      @tag.name = params[:tag][:name]
      if @tag.save
        redirect_to haven_tags_path
      else
        render action: 'edit'
      end
    end

    def destroy
      @tag.destroy
      redirect_to haven_tags_path
    end

    private

    def set_tag
      @tag = Tag.find params[:id]
    end

    def tag_params
      params.require(:tag).permit(:category, :name)
    end
  end
end
