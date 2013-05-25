class Update < Post
  field :content, type: String, default: ""

  belongs_to :thing

  validates :content, presence: true

  default_scope desc(:created_at)
end
