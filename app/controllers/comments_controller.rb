class CommentsController < ApplicationController
  respond_to :json
  load_and_authorize_resource
  before_filter :setup_post

  def index
    @comments = @post.comments
    respond_with @comments
  end

  def create
    @comment = @post.comments.create(params[:comment].merge(author: current_user))
    respond_with @comment
  end

  def destroy
    @comment = @post.comments.find params[:id]
    respond_with @post.comments.delete(@comment)
  end

  private

  def setup_post
    @post = Post.find(params[:post_id])
  end
end
