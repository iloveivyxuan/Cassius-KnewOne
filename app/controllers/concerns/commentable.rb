module Commentable
  extend ActiveSupport::Concern

  included do
    helper_method :read_comments
  end

  def read_comments(post)
    if user_signed_in?
      CommentMessage.read_by_post(current_user, post)
      Notification.mark_as_read_by_context(current_user, :comment, post)
    end
  end
end
