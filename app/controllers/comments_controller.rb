# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  respond_to :json
  load_and_authorize_resource :post

  def index
    @comments = @post.comments.page(params[:page]).per(Settings.comments.per_page)
    respond_with @comments
  end

  def create
    @comment = @post.comments.create(params[:comment].merge(author: current_user))
    respond_with @comment
  end

  def destroy
    @comment = @post.comments.find params[:id]
    respond_with @comment.destroy
  end

end
