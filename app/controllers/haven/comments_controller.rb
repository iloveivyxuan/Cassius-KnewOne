module Haven
  class CommentsController < ApplicationController
    layout 'settings'

    def index
      @comments = Comment.all.page params[:page]
    end

    def destroy
      Comment.find(params[:id]).destroy
      redirect_to haven_comments_path
    end
  end
end
