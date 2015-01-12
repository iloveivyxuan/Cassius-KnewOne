class Impression
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ratable

  belongs_to :author, class_name: 'User', index: true, counter_cache: :fancies_count
  belongs_to :thing, index: true, counter_cache: :fanciers_count
  has_and_belongs_to_many :tags, inverse_of: nil,
                          before_add: :before_add_tag,
                          before_remove: :before_remove_tag

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :state, type: Symbol, default: :none

  validates :state, inclusion: {in: %i(none desired owned)}

  before_save do
    self.score = 0 if self.state != :owned

    if state_changed?
      if state == :desired
        author.inc(desires_count: 1)
        thing.inc(desirers_count: 1)
      end

      if state_was == :desired
        author.inc(desires_count: -1)
        thing.inc(desirers_count: -1)
      end

      if state == :owned
        author.inc(owns_count: 1)
        thing.inc(owners_count: 1)
      end

      if state_was == :owned
        author.inc(owns_count: -1)
        thing.inc(owners_count: -1)
      end
    end
  end

  before_destroy do
    if state_was == :desired
      author.inc(desires_count: -1)
      thing.inc(desirers_count: -1)
    end

    if state_was == :owned
      author.inc(owns_count: -1)
      thing.inc(owners_count: -1)
    end
  end

  scope :desired, -> { where(state: :desired) }
  scope :owned, -> { where(state: :owned) }

  def tags=(tags)
    self.tag_ids = tags.map do |tag|
      tag.is_a?(Tag) ? tag.id : Tag.find_or_create_by(name: tag.to_s).id
    end
  end

  private

  def before_add_tag(tag)
    author.set(tag_ids: [tag.id] + (author.tag_ids - [tag.id]))
    thing.add_to_set(tag_ids: tag.id)
  end

  def before_remove_tag(tag)
    if Impression.where(author_id: author_id, tag_ids: tag.id).count <= 1
      author.pull(tag_ids: tag.id)
    end

    if Impression.where(thing_id: thing_id, tag_ids: tag.id).count <= 1
      thing.pull(tag_ids: tag.id)
    end
  end
end
