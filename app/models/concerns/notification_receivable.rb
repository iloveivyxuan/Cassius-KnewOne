module NotificationReceivable
  extend ActiveSupport::Concern

  included do
    has_many :notifications do
      def mark_as_read
        set read: true
      end

      def build(type, options = {})
        n = super type: type
        n.set_data options
        n
      end
    end
  end

  def notify(type, options = {})
    Notification.build(self, type, options).save
  end
end
