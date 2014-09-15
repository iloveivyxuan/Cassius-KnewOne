class Tag
  include Mongoid::Document
  include Mongoid::Slug

  belongs_to :category

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :things
end
