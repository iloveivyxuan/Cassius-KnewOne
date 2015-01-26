class Tag
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  index name: 1

  validates :name, presence: true, uniqueness: true, length: {maximum: 12}
end
