class Category
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true
  field :things_count, type: Integer, default: 0
  field :users_count, type: Integer, default: 0
  field :priority, type: Integer, default: 0
  mount_uploader :cover, CoverUploader
  field :icon, type: String, default: "fa-tags" # font awesome

  has_and_belongs_to_many :parents, class_name: 'Category', index: true, inverse_of: nil

  field :description, type: String, default: ""

  index name: 1
  validates :name, presence: true, uniqueness: true

  field :depth, type: Integer, default: 0
  before_save { self.depth = self.parent.present? ? self.parent.depth + 1 : 0 }

  scope :top_level, -> { where(depth: 0) }
  scope :second_level, -> { where(depth: 1) }
  scope :third_level, -> { where(depth: 2) }

  scope :prior, -> { desc(:priority, :things_count) }

  def children
    Category.where(parent_ids: self.id)
  end

  # top_level? second_level? third_level?
  [%w(top 0), %w(second 1), %w(third 2)].each do |level|
    define_method("#{level.first}_level?".to_sym) { depth == level.last.to_i }
  end

  def ancestors
    return [] if parent_ids.blank?
    parents | parents.flat_map(&:ancestors)
  end

  def parent
    parents.first
  end

  def parent=(category)
    self.parents = [category]
  end

  def things
    Thing.where(category_ids: self.id)
  end

  def parent_text
    self.parent.name
  end

  def parent_text=(text)
    c = Category.where(name: text.strip).first
    self.parent = c if c
  end

  def parents_text
    self.parents.map(&:name).join(', ')
  end

  def parents_text=(text)
    self.parents = Category.in(name: text.split(/[，,]/).map(&:strip))
  end

  def children_text
    self.children.map(&:name).join(', ')
  end

  def children_text=(text)
    text.split(/[，,]/).each do |name|
      child = Category.find_or_create_by(name: name.strip)
      child.parents << self
      child.set(depth: self.depth + 1)
    end
  end

  include Searchable
  searchable_fields [:name, :_slugs]

  def self.update_things_count
    Category.all.each do |c|
      c.set(things_count: c.things.size)
    end
  end
end
