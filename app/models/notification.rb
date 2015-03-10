class Notification
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include NotificationBuilder

  belongs_to :receiver, class_name: 'User', index: true
  validates :receiver, presence: true

  field :read, type: Boolean, default: false
  field :opened, type: Boolean, default: true
  field :data, type: Hash, default: {}
  field :sender_ids, type: Array, default: []

  field :type, type: Symbol
  validates :type, presence: true

  field :context_type, type: String
  field :context_id, type: String
  index context_type: 1, context_id: 1

  def context
    return if (self.context_type || self.context_id).blank?

    @context ||= self.context_type.constantize.where(id: self.context_id).first
  end

  def context=(record)
    self.context_type = record.class.to_s
    self.context_id = record.id.to_s
  end

  def senders
    @senders ||= User.where(:id.in => self.sender_ids)
  end

  scope :by_context,
        ->(record) { record ? where(context_type: record.class.to_s, context_id: record.id.to_s) : where(context_type: nil, context_id: nil) }

  scope :by_type, ->(type) { where type: type }
  scope :by_types, ->(types) { where :type.in => types }

  scope :by_receiver, ->(user) { where receiver: user }

  # avoiding naming conflict
  scope :marked_as_read, -> { where read: true }
  scope :unread, -> { where read: false }
  scope :unread_or_unopened, -> { self.or({read: false}, {opened: false}) }
  default_scope -> { order_by [:created_at, :desc] }

  def read!
    unless self.read
      set read: true
      receiver.inc unread_notifications_count: -1
    end
  end

  def method_missing(*args)
    if args[0][-1] == '='
      self.data[args[0][0..-2].to_sym] = args[1]
    else
      self.data[args[0]]
    end
  end

  def orphan?
    self.context_id.present? && context.nil?
  end

  def set_data(options = {})
    self.context = options.delete :context if options[:context]

    if sender = options.delete(:sender)
      self.sender_ids<< sender.id.to_s
    end

    if options[:sender_id].present? && (sender = User.where(id: options.delete(:sender_id)).first)
      self.sender_ids<< sender.id.to_s
    end

    self.sender_ids.uniq!

    options.each do |k, v|
      send :"#{k}=", v
    end
  end

  def self.mark_as_read_by_context(receiver, context)
    notifications = receiver.notifications.unread_or_unopened.by_context(context)

    return unless notifications.exists?

    receiver.inc unread_notifications_count: -notifications.count
    notifications.set read: true, opened: true
  end

  # after_create :push_to_apn

  private

  def push_to_apn
    return unless receiver.apple_device_token
    badge = receiver.notifications.unread.count
    APN.notify_async(receiver.apple_device_token, {notification_id: id, badge: badge})
  end
end
