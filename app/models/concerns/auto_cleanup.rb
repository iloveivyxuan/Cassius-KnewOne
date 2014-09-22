module AutoCleanup
  extend ActiveSupport::Concern

  included do
    after_destroy :cleanup_relevant_activities
    after_destroy :cleanup_relevant_notifications
  end

  private

  def cleanup_relevant_activities
    Activity.by_reference(self).update_all(visible: false)
    Activity.by_source(self).update_all(visible: false)
  end

  def cleanup_relevant_notifications
    Notification.where(context_type: self.class.to_s, context_id: id.to_s).destroy
  end
end
