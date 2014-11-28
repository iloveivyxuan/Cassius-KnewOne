module Haven
  class ArticlesController < Haven::ApplicationController
    include DestroyDraft

    layout 'settings'
    before_action :set_article, except: [:index, :create, :new]

    def index
      @articles = Article.all.desc(:created_at).page params[:page]
    end

    def edit

    end

    def new
      @article = Article.new
      @article.author = current_user
    end

    def update
      @article.update_attributes article_params

      redirect_to haven_articles_url
    end

    def create
      @article = Article.new article_params
      @article.author = current_user if params[:article][:author_id].blank?

      if @article.save
        redirect_to haven_articles_url
      else
        render 'new'
      end
    end

    def destroy
      @article.destroy

      redirect_to haven_articles_url
    end

    def photo
      if params[:photo]
        @article.photo[params[:thing]] = params[:photo]
        @article.save
      end

      respond_to do |format|
        format.json { render json: @article.photo[params[:thing]] }
      end
    end

    private

    def article_params
      params.require(:article).permit!
    end

    def set_article
      @article = Article.find(params[:id])
    end
  end
end
