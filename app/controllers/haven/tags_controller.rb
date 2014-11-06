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
      categories = params[:tag][:categories_text].split(/[，,]/).map { |name| Category.where(name: name).first }.compact.uniq
      tag = Tag.new(name: params[:tag][:name])
      categories.each { |c| tag.categories << c }
      if tag.save
        redirect_to haven_tags_path
      else
        render 'new'
      end
    end

    def edit
    end

    def update
      new_category = Category.where(name: tag_params.values.first).first
      @tag.category = new_category if new_category
      @tag.name = params[:tag][:name]
      params[:tag][:categories_text].split(/[，,]/).map { |t| Category.where(name: t.strip).first  }.each do |c|
        @tag.categories << c if c
      end
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
      params.require(:tag).permit(:categories_text, :name)
    end
  end
end
