class Activity
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user
  index({user_id: 1})

  field :visible, type: Boolean, default: true

  field :type, type: Symbol
  validates :type, presence: true

  field :reference_union, type: String
  index({reference_union: 1})

  def reference
    return if self.reference_union.blank?

    reference_type, reference_id = self.reference_union.split('_')
    @_reference ||= reference_type.constantize.where(id: reference_id).first
  end

  def reference=(record)
    self.reference_union = "#{record.class.to_s}_#{record.id.to_s}"
  end

  field :source_union, type: String
  index({source_union: 1})

  def source
    return if self.source_union.blank?

    source_type, source_id = self.source_union.split('_')
    @_source ||= source_type.constantize.where(id: source_id).first
  end

  def source=(record)
    self.source_union = "#{record.class.to_s}_#{record.id.to_s}"
  end

  default_scope -> { desc(:created_at) }

  scope :visible, -> { where visible: true }
  scope :by_users, ->(users) { where(:user_id.in => users.map(&:id)) }
  scope :by_reference,
        ->(record) { where reference_union: "#{record.class.name}_#{record.id.to_s}" }
  scope :by_type, ->(type) { where type: type }
  scope :by_types, ->(*types) { where :type.in => types }

  def identifier
    [source_union, reference_union].compact.join('_')
  end
end
