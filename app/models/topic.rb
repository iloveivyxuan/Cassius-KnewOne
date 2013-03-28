class Topic < Post
  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  belongs_to :group

  validates :content, presence: true

  default_scope desc(:commented_at)
end
