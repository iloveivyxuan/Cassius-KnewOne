class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :title, type: String

  slug :title

  validates :title, presence: true
end

