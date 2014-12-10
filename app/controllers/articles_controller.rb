class ArticlesController < ApplicationController
  prepend_before_action :require_signed_in
  before_action :set_article

  def vote
    @article.vote(current_user)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @article} }
    end
  end

  def unvote
    @article.unvote(current_user)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @article} }
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end
end
