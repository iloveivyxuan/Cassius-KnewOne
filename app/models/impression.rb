class Impression
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ratable

  belongs_to :author, class_name: 'User', index: true
  belongs_to :thing, index: true
  has_and_belongs_to_many :tags, inverse_of: nil,
                          before_add: :before_add_tag,
                          before_remove: :before_remove_tag

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :fancied, type: Boolean, default: false
  field :state, type: Symbol, default: :none

  validates :state, inclusion: {in: %i(none desired owned)}

  before_save do
    if state_changed?
      if state == :desired
        self.fancied = true
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

    if fancied_changed?
      if fancied
        author.inc(fancies_count: 1)
        thing.inc(fanciers_count: 1)
      end

      if fancied_was
        author.inc(fancies_count: -1)
        thing.inc(fanciers_count: -1)
      end
    end
  end

  after_save do
    destroy unless fancied || state == :owned
  end

  before_destroy do
    reload

    if fancied
      author.inc(fancies_count: -1)
      thing.inc(fanciers_count: -1)
    end

    if state == :desired
      author.inc(desires_count: -1)
      thing.inc(desirers_count: -1)
    end

    if state == :owned
      author.inc(owns_count: -1)
      thing.inc(owners_count: -1)
    end
  end

  scope :fancied, -> { where(fancied: true) }
  scope :desired, -> { where(state: :desired) }
  scope :owned, -> { where(state: :owned) }

  def tag_names=(names)
    self.tags = names.map do |name|
      Tag.find_or_create_by(name: name.to_s)
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
