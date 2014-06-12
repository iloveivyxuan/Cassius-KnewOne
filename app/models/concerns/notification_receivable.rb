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
end
