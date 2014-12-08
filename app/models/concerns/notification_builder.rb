module NotificationBuilder
  extend ActiveSupport::Concern

  included do
    around_create :cleanup_similar
  end

  module ClassMethods
    def build(receiver, type, options = {})
      options.symbolize_keys!

      receiver_id = receiver.is_a?(String) ? receiver : receiver.id.to_s

      n = new receiver_id: receiver_id, type: type
      n.set_data options

      receiver.inc(unread_notifications_count: 1)

      n
    end
  end

  private

  def cleanup_similar
    similar = find_unread_similar
    if similar && self.sender_ids.any?
      self.sender_ids.concat(similar.sender_ids).uniq!
    end

    yield

    similar.destroy if similar
  end

  def find_unread_similar
    return nil unless self.context
    Notification.unread.by_type(self.type).by_receiver(self.receiver).by_context(self.context).first
  end
end
