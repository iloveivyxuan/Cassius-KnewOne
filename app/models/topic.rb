class Topic < Post
  field :content, type: String, default: ""

  belongs_to :group

  validates :content, presence: true

  default_scope desc(:commented_at)
end
