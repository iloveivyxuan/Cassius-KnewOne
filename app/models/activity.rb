class Activity
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  index created_at: -1
  index({ type: 1, reference_union: 1, user_id: 1 })

  #type common rules: {action}_{reference}
  #examples: new_review, fancy_thing
  field :type, type: Symbol
  validates :type, presence: true

  field :reference_union, type: String
  index({reference_union: 1})

  field :source_union, type: String
  index({source_union: 1})

  field :visible, type: Boolean, default: true

  belongs_to :user
  index({user_id: 1, created_at: -1})

  default_scope -> { desc(:created_at) }

  scope :visible, -> { where(visible: true) }
  scope :by_users, ->(users) { where(:user_id.in => users.map(&:id)) }
  scope :by_type, ->(type) { where type: type }
  scope :by_types, ->(*types) { where :type.in => types }
  scope :by_reference, ->(record) do
    where reference_union: "#{record.class.name}_#{record.id.to_s}"
  end
  scope :by_source, ->(record) do
    where source_union: "#{record.class.name}_#{record.id.to_s}"
  end
  scope :since_date, ->(date) { where :created_at.gte => date.to_time.to_i }
  scope :until_date, ->(date) { where :created_at.lt => date.next_day.to_time.to_i }

  TYPES = %i(fancy_thing own_thing new_thing
             new_feeling love_feeling
             new_review love_review
             love_topic new_topic
             fancy_list add_to_list
             comment follow_user)

  def tmpl
    self.type.to_s.split("_").last
  end

  def reference_id
    reference_union.split('_').last
  end

  def reference(with_deleted = false)
    return if self.reference_union.blank?

    reference_type, reference_id = self.reference_union.split('_')
    @_reference ||= with_deleted ? reference_type.constantize.unscoped.where(id: reference_id).first : reference_type.constantize.where(id: reference_id).first

    unless @_reference
      children = source.try(reference_type.underscore.pluralize)
      if children
        children = children.unscoped if with_deleted
        @_reference ||= children.where(id: reference_id).first
      end
    end

    @_reference
  end

  def reference=(record)
    self.reference_union = "#{record.class.to_s}_#{record.id.to_s}"
    @_reference = record
  end

  def source_id
    source_union.split('_').last
  end

  def source(with_deleted = false)
    return if self.source_union.blank?

    source_type, source_id = self.source_union.split('_')
    @_source ||= with_deleted ? source_type.constantize.unscoped.where(id: source_id).first : source_type.constantize.where(id: source_id).first
  end

  def source=(record)
    self.source_union = "#{record.class.to_s}_#{record.id.to_s}"
    @_source = record
  end

  def related_thing_id
    case self.type
    when :new_thing, :fancy_thing, :desire_thing, :own_thing, :add_to_list then self.reference_id
    when :new_review, :love_review, :new_feeling then self.source_id
    else nil
    end
  end

  def related_thing
    case self.type
    when :new_thing, :fancy_thing, :desire_thing, :own_thing, :add_to_list then self.reference
    when :new_review, :love_review, :new_feeling then self.source
    else nil
    end
  end

  def related_thing_list_id
    case self.type
    when :fancy_list then self.reference_id
    when :add_to_list then self.source_id
    else nil
    end
  end

  def related_thing_list
    case self.type
    when :fancy_list then self.reference
    when :add_to_list then self.source
    else nil
    end
  end

  def self.eager_load!(activities, models = [Thing, ThingList, Review, Feeling, Impression])
    activities = activities.to_a

    unions = activities.map(&:reference_union) | activities.map(&:source_union)
    records = {}

    models.each do |model|
      ids = unions.each_with_object([]) do |s, ids|
        model_name, id = s.split('_')
        ids << id if model_name == model.name
      end

      next if ids.empty?

      model.in(id: ids).each do |record|
        records["#{model.name}_#{record.id}"] = record
      end
    end

    activities.each do |a|
      a.reference = records[a.reference_union] if records.has_key?(a.reference_union)
      a.source = records[a.source_union] if records.has_key?(a.source_union)
    end

    activities
  end
end
