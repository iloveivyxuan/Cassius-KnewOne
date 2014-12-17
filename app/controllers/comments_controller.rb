class CommentsController < ApplicationController
  include MarkReadable

  load_and_authorize_resource :post
  load_and_authorize_resource :thing_list
  load_and_authorize_resource :comment, :through => [:post, :thing_list]

  respond_to :html, :js
  layout false

  def index
    mark_read @post || @thing_list

    comment = @comments.where(id: params[:from_id]).first
    if comment
      offset = @comments.gte(created_at: comment.created_at).size
      limit = (offset.to_f / Settings.comments.per_page).ceil * Settings.comments.per_page
      @comments = @comments.limit(limit)
    else
      @comments = @comments.page(params[:page]).per(Settings.comments.per_page)
    end

    respond_with @comments
  end

  def create
    @comment.author = current_user

    if @comment.save
      respond_with @comment
      @comment.author.log_activity :comment, (@post || @thing_list), check_recent: true
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
