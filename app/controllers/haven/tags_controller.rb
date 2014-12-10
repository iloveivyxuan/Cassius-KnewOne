module Haven
  class TagsController < Haven::ApplicationController
    layout 'settings'
    before_action :set_tag, only: [:edit, :update, :destroy]

    def index
      @tags = Tag.all
      if params[:category]
        @tags = Category.where(name: /#{params[:category]}/).map(&:tags).flatten
      end
      respond_to do |format|
        format.html
        format.csv do
          lines = [%w(一级分类 二级分类 三级分类 产品数)]
          Tag.all.includes(:categories).desc(:things_count).each do |tag|
            inners = tag.categories
            primaries = inners.map(&:category)
            primaries.zip(inners).each do |embed|
              lines << [embed.first.try(:name), embed.last.try(:name), tag.name, tag.things_count]
            end
          end
          col_sep = (params[:platform] == 'numbers') ? ',' : ';'

          csv = CSV.generate :col_sep => col_sep do |csv|
            lines.each { |l| csv<< l }
          end

          if params[:platform] != 'numbers'
            send_data csv.encode 'gb2312', :replace => ''
          else
            send_data csv, :replace => ''
          end
        end
      end
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
      @tag.name = params[:tag][:name]
      @tag.description = params[:tag][:description]
      @tag.categories.clear
      params[:tag][:categories_text].split(/[，,]/).map { |t| Category.where(name: t.strip).first  }.each do |c|
        @tag.categories << c if c
      end
      if @tag.save
        redirect_to haven_tags_path
      else
        flash[:error] = @tag.errors.full_messages
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
      params.require(:tag).permit(:categories_text, :name, :description)
    end
  end
end
