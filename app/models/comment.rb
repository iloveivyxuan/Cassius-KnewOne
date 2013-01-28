class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String

  embedded_in :post
  belongs_to :author, class_name: 'User'

  validates :content, presence: true, length: {maximum: 255}

  default_scope desc(:created_at)
end
