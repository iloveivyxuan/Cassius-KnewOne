class Review < Post
  field :content, type: String, default: ""

  belongs_to :thing

  validates :content, presence: true
end
