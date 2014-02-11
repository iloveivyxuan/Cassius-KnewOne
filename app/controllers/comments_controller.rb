# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  respond_to :json
  load_and_authorize_resource :post

  after_action only: :create do
    session[:cooldown] = Time.now.to_i
  end

  before_action only: :create do
    return if current_user.staff?
    head :not_acceptable if session[:cooldown].present? && Time.now.to_i < (session[:cooldown].to_i + 10)
  end

  def index
    @comments = @post.comments.page(params[:page]).per(Settings.comments.per_page)
    respond_with @comments
  end

  def create
    @comment = @post.comments.create(comment_params.merge(author: current_user))
    respond_with @comment
  end

  def destroy
    @comment = @post.comments.find params[:id]
    respond_with @comment.destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
