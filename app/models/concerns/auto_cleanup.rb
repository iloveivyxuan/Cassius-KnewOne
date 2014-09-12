module AutoCleanup
  extend ActiveSupport::Concern

  included do
    after_destroy :cleanup_relevant_activities
    after_destroy :cleanup_relevant_notifications
  end

  private

  def cleanup_relevant_activities
    union = "#{self.class.to_s}_#{id.to_s}"
    Activity.where(reference_union: union).update_all(visible: false)
    Activity.where(source_union: union).update_all(visible: false)
  end

  def cleanup_relevant_notifications
    Notification.where(context_type: self.class.to_s, context_id: id.to_s).destroy
  end
end
