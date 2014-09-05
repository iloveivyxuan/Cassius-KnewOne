class CommentsController < ApplicationController
  include MarkReadable
  respond_to :json
  load_and_authorize_resource :post

  def index
    mark_read @post

    comment = @post.comments.where(id: params[:from_id]).first
    if comment
      @comments = @post.comments.gte(created_at: comment.created_at)
    else
      @comments = @post.comments.page(params[:page]).per(Settings.comments.per_page)
    end

    respond_with @comments
  end

  def create
    authorize! :create, Comment
    authorize! :create, @post if @post.class == Topic
    @comment = @post.comments.create(comment_params.merge(author: current_user))
    @comment.author.log_activity :comment, @comment.post, check_recent: true
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
