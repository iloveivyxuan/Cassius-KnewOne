class Tag
  include Mongoid::Document
  include Mongoid::Slug

  belongs_to :category

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  def things
    Thing.published.any_in(tags: [name])
  end
end
