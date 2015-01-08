class Tag
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true
end
