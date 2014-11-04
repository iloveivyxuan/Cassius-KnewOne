class Category
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true
  field :things_count, type: Integer, default: 0
  field :priority, type: Integer, default: 0
  mount_uploader :cover, CoverUploader
  field :icon, type: String, default: "fa-tags" # font awesome

  field :thing_ids, type: Array, default: []

  has_many :inner_categories, class_name: "Category", inverse_of: :category
  belongs_to :category, class_name: "Category", inverse_of: :inner_categories

  has_and_belongs_to_many :users

  field :description, type: String, default: ""

  validates :name, presence: true, uniqueness: true

  scope :prior, -> { desc(:priority, :things_count) }
  scope :primary, -> { where(category: nil) }

  has_many :tags

  def things
    Thing.published.any_in(categories: [name])
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

  class << self
    def find_and_minus(name)
      c = where(name: name).first
      if c.present? && c.things_count.try(:>, 0)
        c.inc things_count: -1
      end
    end

    def find_and_plus(name)
      c = where(name: name).first
      if c.present?
        c.inc things_count: 1
      else
        Category.create name: name, things_count: 1
      end
    end
  end

  def self.update_things_count
    Category.all.each do |c|
      if c.primary_category?
        c.set(things_count: c.inner_categories.map(&:things_count).reduce(&:+)) unless c.inner_categories.empty?
      end
      c.set(things_count: c.tags.map(&:things_count).reduce(&:+)) unless c.tags.empty?
    end
  end

  def self.update_thing_ids
    Category.all.each do |c|
      if c.primary_category?
        c.thing_ids = c.inner_categories.map(&:thing_ids).flatten.uniq unless c.inner_categories.empty?
      end
      c.thing_ids = c.tags.map(&:thing_ids).flatten.uniq unless c.tags.empty?
      c.save
    end
  end

end
