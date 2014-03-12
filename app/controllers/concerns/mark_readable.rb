module MarkReadable
  extend ActiveSupport::Concern

  included do
    helper_method :auto_mark_read
  end

  def mark_read(context)
    if user_signed_in?
      Notification.mark_as_read_by_context(current_user, context)
    end
  end
end
