class Feeling < Post
  include Rateable
  include Aftermath

  field :photo_ids, type: Array, default: []

  belongs_to :thing, counter_cache: true

  validates :content, presence: true, length: { maximum: 140 }

  default_scope -> { desc(:lovers_count, :created_at) }

end
