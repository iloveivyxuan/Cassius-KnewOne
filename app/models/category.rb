class Category
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true
  field :things_count, type: Integer, default: 0
  field :priority, type: Integer, default: 0
  mount_uploader :cover, CoverUploader
  field :icon, type: String, default: "fa-tags" # font awesome

  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true

  scope :prior, -> { desc(:priority, :things_count) }

  has_many :tags

  def things
    Thing.published.any_in(categories: [name])
  end

  class << self
    def find_and_minus(name)
      c = where(name: name).first
      if c.present? and c.things_count > 0
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
end
