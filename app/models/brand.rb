class Brand
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name, history: true

  index name: 1

  validates :name, presence: true, uniqueness: true, case_sensitive: false

  has_many :things
end
