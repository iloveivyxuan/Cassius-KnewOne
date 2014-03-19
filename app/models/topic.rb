class Topic < Post
  field :is_top, type: Boolean, default: false

  belongs_to :group

  default_scope -> { desc(:is_top, :commented_at) }
end
