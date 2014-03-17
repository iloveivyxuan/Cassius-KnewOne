class Activity
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user

  field :visible, type: Boolean, default: true

  field :type, type: Symbol
  validates :type, presence: true

  field :reference_type, type: String
  field :reference_id, type: String

  def reference
    return if (self.reference_type || self.reference_id).blank?

    @reference ||= self.reference_type.constantize.where(id: self.reference_id).first
  end

  def reference=(record)
    self.reference_type = record.class.to_s
    self.reference_id = record.id.to_s
  end

  default_scope -> { desc(:created_at) }

  scope :visible, -> { where visible: true }
  scope :by_users, ->(users) { where(:user.in => users) }
  scope :by_reference,
        ->(record) { record ? where(reference_type: record.class.to_s, reference_id: record.id.to_s) : where(reference_type: nil, reference_id: nil) }
  scope :by_type, ->(type) { where type: type }
  scope :by_types, ->(types) { where :type.in => types }
end
