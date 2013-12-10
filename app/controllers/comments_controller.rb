# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  respond_to :json
  load_and_authorize_resource :post
  load_and_authorize_resource through: :post

  def index
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
