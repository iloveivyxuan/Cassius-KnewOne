class Category
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true
  field :things_count, type: Integer, default: 0

  mount_uploader :cover, CoverUploader

  validates :name, presence: true, uniqueness: true

  default_scope -> { desc(:things_count) }

  def things(desc_by = :fanciers_count)
    Thing.unscoped.published.any_in(categories: [name]).desc(desc_by)
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
