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

    embeds_one :notification_setting, autobuild: true
  end

  def notify(type, options = {})
    if (options[:sender] && options[:sender] == self) || (options[:sender_id] && options[:sender_id] == self.id.to_s)
      return
    end

    Notification.build(self, type, options).save
  end
end
