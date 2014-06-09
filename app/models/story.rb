class Story < Post
  include Mongoid::MultiParameterAttributes

  field :occured_at, type: Date

  validates :title, presence: true
  validates :content, presence: true
  validates :occured_at, presence: true

  default_scope -> { desc(:occured_at) }

  scope :living, -> { where :thing_id.ne => nil }

  belongs_to :thing
end
