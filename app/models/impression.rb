class Impression
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup
  include Ratable

  belongs_to :author, class_name: 'User'
  belongs_to :thing, index: true
  index author_id: 1, thing_id: 1

  has_and_belongs_to_many :tags, inverse_of: nil,
                          before_add: :before_add_tag,
                          before_remove: :before_remove_tag

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :fancied, type: Boolean, default: false
  field :state, type: Symbol, default: :none

  validates :description, length: {maximum: 140}

  field :fancied_at, type: Time
  field :desired_at, type: Time
  field :owned_at, type: Time

  STATES = {
    none: '',
    desired: '想要',
    owned: '拥有'
  }
  validates :state, inclusion: {in: STATES.keys}

  scope :by_user, ->(user) { where(author: user) }
  scope :of_thing, ->(thing) { where(thing: thing) }
  scope :by_tag, ->(tag) { where(tag_ids: tag.id) }

  before_save do
    now = Time.now.utc if state_changed? || fancied_changed?

    if state_changed?
      if state == :desired
        self.fancied = true
        self.desired_at = now
        author.inc(desires_count: 1)
        thing.inc(desirers_count: 1)

        author.log_activity(:desire_thing, thing, source: self, check_recent: true)
      end

      if state_was == :desired
        author.inc(desires_count: -1)
        thing.inc(desirers_count: -1)
      end

      if state == :owned
        self.owned_at = now
        author.inc(owns_count: 1)
        thing.inc(owners_count: 1)

        author.log_activity(:own_thing, thing, source: self, check_recent: true)
      end

      if state_was == :owned
        author.inc(owns_count: -1)
        thing.inc(owners_count: -1)
      end
    end

    if fancied_changed?
      if fancied
        self.fancied_at = now
        author.inc(fancies_count: 1)
        thing.inc(fanciers_count: 1)

        if author != thing.author
          author.log_activity(:fancy_thing, thing, source: self, check_recent: true)
          thing.author.notify(:fancy_thing, context: thing, sender: author, opened: false)
        end
      end

      if fancied_was
        author.inc(fancies_count: -1)
        thing.inc(fanciers_count: -1)
      end
    end
  end

  after_update do
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

    tags.clear
  end

  scope :fancied, -> { where(fancied: true).desc(:fancied_at) }
  scope :desired, -> { where(state: :desired).desc(:desired_at) }
  scope :owned, -> { where(state: :owned).desc(:owned_at) }

  def tag_names
    return [] if tag_ids.blank?

    Tag.only(:id, :name).in(id: tag_ids).sort_by do |t|
      tag_ids.index(t.id)
    end.map(&:name)
  end

  def tag_names=(names)
    names = names.map(&:to_s)

    names.each do |name|
      tag = Tag.find_or_create_by(name: name)
      self.tags << tag unless self.tags.include?(tag)
    end

    self.tags.nin(name: names).each do |tag|
      self.tags.delete(tag)
    end

    self.tag_ids = names.map do |name|
      Tag.find_by(name: name).id
    end
  end

  private

  def before_add_tag(tag)
    author.set(tag_ids: [tag.id] + (author.tag_ids - [tag.id]))

    thing.add_tag(tag)
    thing.fix_tag_counts
  end

  def before_remove_tag(tag)
    if Impression.where(author_id: author_id, tag_ids: tag.id).count <= 1
      author.pull(tag_ids: tag.id)
    end

    thing.remove_tag(tag)
    thing.fix_tag_counts
  end
end
