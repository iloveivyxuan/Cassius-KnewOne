class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String

  belongs_to :author, class_name: "User", inverse_of: :post

  embeds_many :comments

  validates :title, presence: true
end
