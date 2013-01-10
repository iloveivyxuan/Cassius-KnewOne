class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  field :title, type: String
  slug :title

  belongs_to :author, class_name: "User", inverse_of: :post

  validates :title, presence: true

  default_scope desc(:created_at)
end
