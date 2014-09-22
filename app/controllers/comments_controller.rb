class CommentsController < ApplicationController
  include MarkReadable

  load_and_authorize_resource :post
  load_and_authorize_resource :thing_list
  load_and_authorize_resource :comment, :through => [:post, :thing_list]

  respond_to :json

  def index
    mark_read @post || @thing_list

    comment = @comments.where(id: params[:from_id]).first
    if comment
      comments_from_created_at = @comments.gte(created_at: comment.created_at)
    end

    if !comment || comments_from_created_at.size < Settings.comments.per_page
      @comments = @comments.page(params[:page]).per(Settings.comments.per_page)
    else
      @comments = comments_from_created_at
    end

    respond_with @comments
  end

  def create
    @comment.author = current_user
    @comment.save
    respond_with @comment

    @comment.author.log_activity :comment, (@post || @thing_list), check_recent: true
  end

  def destroy
    @comment.destroy
    respond_with @comment
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
