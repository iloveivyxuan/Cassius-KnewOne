class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  belongs_to :author, class_name: "User", inverse_of: :post

  validates :title, presence: true
end
