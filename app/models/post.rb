class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  belongs_to :author, class_name: "User", inverse_of: :post

  validates :title, presence: true

  default_scope desc(:created_at)
end
