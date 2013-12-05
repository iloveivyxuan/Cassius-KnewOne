class Story < Post
  include Mongoid::MultiParameterAttributes

  field :occured_at, type: Date
  validates :occured_at, presence: true
  default_scope { desc(:occured_at) }

  belongs_to :thing
end
