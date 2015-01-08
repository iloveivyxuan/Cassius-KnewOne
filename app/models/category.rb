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

  has_many :children, class_name: 'Category', inverse_of: :parent, foreign_key: :category_id
  belongs_to :parent, class_name: 'Category', inverse_of: :children, foreign_key: :category_id

  field :description, type: String, default: ""

  validates :name, presence: true, uniqueness: true

  field :depth, type: Integer, default: 0
  before_save { self.depth = self.parent.present? ? self.parent.depth + 1 : 0 }

  scope :top_level, -> { where(depth: 0) }
  scope :second_level, -> { where(depth: 1) }
  scope :third_level, -> { where(depth: 2) }

  scope :prior, -> { desc(:priority, :things_count) }
  scope :primary, -> { where(category: nil) }
  scope :inner, -> { ne(category: nil) }

  def things
    Thing.any_in(id: thing_ids)
  end

  def primary_category?
    self.category.nil?
  end

  def primary_category
    self.category.name
  end

  def primary_category=(text)
    pc = Category.where(name: text.strip).first
    self.category = pc if pc
  end

  def inner_categories_text
    self.inner_categories.map(&:name).join(",")
  end

  def inner_categories_text=(text)
    inners = text.split(/[，,]/).map { |c| Category.find_or_create_by(name: c.strip) }
    self.inner_categories = inners
  end

  include Searchable
  searchable_fields [:name, :_slugs]

  def self.update_things_count
    Category.all.each do |c|
      c.set(things_count: c.things.size)
    end
  end

  def self.update_thing_ids
    # inner categories
    Category.ne(category: nil).each do |c|
      c.thing_ids = c.tags.map(&:thing_ids).flatten.uniq unless c.tags.empty?
      c.save
    end
    # primary categories
    Category.where(category: nil).each do |c|
      c.thing_ids = c.inner_categories.map(&:thing_ids).flatten.uniq unless c.inner_categories.empty?
      c.save
    end
  end

  def self.update_tags
    Category.where(category: nil).each do |c|
      c.tags.clear
      tags = c.inner_categories.map(&:tags).flatten.uniq
      tags.each { |tag| c.tags << tag }
    end
  end

end
