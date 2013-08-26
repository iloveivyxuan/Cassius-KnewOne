class Feature < Post
  field :priority, type: Integer, default: 0
  field :fanciers_count, type: Integer, default: 0

  default_scope desc(:priority)

  belongs_to :thing
end
