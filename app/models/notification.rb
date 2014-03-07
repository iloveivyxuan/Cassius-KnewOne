class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :receiver, class_name: 'User'
  validates :receiver, presence: true

  field :read, type: Boolean, default: false
  field :data, type: Hash, default: {}

  field :type, type: Symbol
  validates :type, presence: true

  field :context_type, type: String
  field :context_id, type: String

  def context
    return if (self.context_type || self.context_id).blank?

    @context ||= self.context_type.constantize.find(context_id)
  end

  def context=(record)
    self.context_type = record.class.to_s
    self.context_id = record.id.to_s
  end

  scope :by_context, ->(record) { where context_type: record.class.to_s, context_id: record.id.to_s }

  scope :by_type, ->(type) { where type: type }

  scope :by_receiver, ->(user) { where receiver: user }

  # avoiding naming conflict
  scope :marked_as_read, -> { where read: true }
  scope :unread, -> { where read: false }
  default_scope -> { order_by [:updated_at, :desc] }

  def read!
    update read: true
  end

  def method_missing(*args)
    if args[0][-1] == '='
      self.data[args[0][0..-2].to_sym] = args[1]
    else
      self.data[args[0]]
    end
  end

  def self.build(receiver, type, options = {})
    receiver_id = receiver.is_a?(String) ? receiver : receiver.id.to_s

    n = Notification.new receiver_id: receiver_id, type: type

    n.context = options.delete :context if options[:context]
    options.each do |k, v|
      n.data[k] = v
    end

    n
  end
end
