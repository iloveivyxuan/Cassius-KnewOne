class Notification
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :receiver, class_name: 'User'
  validates :receiver, presence: true

  field :read, type: Boolean, default: false
  field :data, type: Hash, default: {}
  field :sender_ids, type: Array, default: []

  field :type, type: Symbol
  validates :type, presence: true

  field :context_type, type: String
  field :context_id, type: String

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

  scope :by_receiver, ->(user) { where receiver: user }

  # avoiding naming conflict
  scope :marked_as_read, -> { where read: true }
  scope :unread, -> { where read: false }
  default_scope -> { order_by [:created_at, :desc] }

  # potential timing sequence issue
  before_create do
    @similar = find_unread_similar
    if @similar && self.sender_ids.any?
      self.sender_ids.concat(@similar.sender_ids).uniq!
    end
  end

  after_create do
    @similar.destroy if @similar
  end

  def read!
    set read: true
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

  def find_unread_similar
    return nil unless self.context
    Notification.unread.by_type(self.type).by_receiver(self.receiver).by_context(self.context).first
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
      self.data[k] = v
    end
  end

  def self.build(receiver, type, options = {})
    options.symbolize_keys!

    receiver_id = receiver.is_a?(String) ? receiver : receiver.id.to_s

    n = new receiver_id: receiver_id, type: type
    n.set_data options

    n
  end

  def self.mark_as_read_by_context(receiver, context)
    receiver.notifications.unread.by_context(context).set read: true
  end

  def self.batch_mark_as_read(ids)
    Notification.where(:id.in => ids).set read: true
  end
end
