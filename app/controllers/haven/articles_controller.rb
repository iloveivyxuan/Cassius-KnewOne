module Haven
  class ArticlesController < ApplicationController
    layout 'settings'
    before_action :set_article, except: [:index, :create, :new]

    def index
      @articles = Article.all.page params[:page]
    end

    def edit

    end

    def new
      @article = Article.new
    end

    def update
      @article.update_attributes article_params
    end

    def create
      article = Article.new article_params
      article.author = current_user

      if article.save
        redirect_to haven_articles_url
      else
        render 'new'
      end
    end

    def destroy
      @article.destroy

      redirect_to haven_articles_url
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
