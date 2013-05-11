class Topic < Post
  field :content, type: String, default: ""
  field :is_top, type: Boolean, default: false

  belongs_to :group

  validates :content, presence: true

  default_scope desc(:is_top, :commented_at)
end
