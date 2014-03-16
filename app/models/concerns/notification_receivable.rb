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

    case self.notification_setting.send type
      when :following
        sender = options[:sender] || User.find(options[:sender_id])
        Notification.build(self, type, options).save if self.followers.include? sender
      when :all
        Notification.build(self, type, options).save
      when nil
        Notification.build(self, type, options).save
      else
        nil
    end
  end
end
