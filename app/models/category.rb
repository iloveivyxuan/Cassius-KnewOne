class Category
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true
  field :things_count, type: Integer, default: 0
  field :priority, type: Integer, default: 0
  mount_uploader :cover, CoverUploader
  field :icon, type: String, default: "fa-tags" # font awesome

  has_many :inner_categories, class_name: "Category", inverse_of: :category
  belongs_to :category, class_name: "Category", inverse_of: :inner_categories

  before_save :update_things_count

  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true

  scope :prior, -> { desc(:priority, :things_count) }

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
    inners = text.split(/[，,]/).map { |c| Category.where(name: c.strip).first }
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

  private

  def update_things_count
    if self.primary_category?
      self.things_count = self.inner_categories.map(&:things_count).reduce(&:+)
    end
  end
end
