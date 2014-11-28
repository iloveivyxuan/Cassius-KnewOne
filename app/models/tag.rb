class Tag
  include Mongoid::Document
  include Mongoid::Slug

  has_and_belongs_to_many :categories, after_add: :add_belonging_tags

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :things, counter_cache: true

  field :things_count, type: Integer, default: 0

  def self.find_by_sequence(name)
    return all if name.blank?
    str = Regexp.escape(name.gsub(/[^\u4e00-\u9fa5a-zA-Z0-9_-]+/, ''))
    where(name: /^#{str}/i)
  end

  def self.update_things_count
    Tag.all.each { |t| t.set(things_count: t.things.size) }
  end

  def categories_text
    self.categories.inner.map(&:name).join(",")
  end

  def add_belonging_tags(category)
    category.tags << self
  end

  include Searchable

  def as_indexed_json(options={})
    {
      name: name,
      slug: slug,
    }
  end
end
