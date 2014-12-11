module NotificationReceivable
  extend ActiveSupport::Concern

  included do
    has_many :notifications do
      def build(type, options = {})
        n = super type: type
        n.set_data options
        n
      end
    end

    embeds_one :notification_setting, autobuild: true

    field :unread_notifications_count, type: Integer, default: 0
  end

  def notify(type, options = {})
    if (options[:sender] && options[:sender] == self) || (options[:sender_id] && options[:sender_id] == self.id.to_s)
      return
    end

    case self.notification_setting.try type
      when :following
        if options[:sender]
          sender = options[:sender]
        elsif options[:sender_id]
          sender = User.where(id: options[:sender_id]).first
        end
        Notification.build(self, type, options).save if !defined?(sender) || (sender && self.followings.include?(sender))
      when :all
        Notification.build(self, type, options).save
      when :none
        true
      else
        Notification.build(self, type, options).save
    end
  end

  def read_notificaitions(notifications)
    notifications.set(read: true)
    set unread_notifications_count: self.notifications.unread.count
  end
end
