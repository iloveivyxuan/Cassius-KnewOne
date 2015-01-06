class Review < Post
  include Ratable
  include Aftermath
  include Atable

  field :is_top, type: Boolean, default: false

  belongs_to :thing, index: true

  validates :title, presence: true
  validates :content, presence: true

  scope :living, -> { where :thing_id.ne => nil }
  scope :created_between, ->(from, to) { where :created_at.gt => from, :created_at.lt => to }

  include Rankable

  def calculate_heat
    (lovers_count + comments_count) * freezing_coefficient
  end

  need_aftermath :create, :vote
end
