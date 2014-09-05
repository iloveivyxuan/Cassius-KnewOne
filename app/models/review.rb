class Review < Post
  include Ratable
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :thing, inverse_of: :single_reviews, index: true

  validates :title, presence: true
  validates :content, presence: true

  scope :living, -> { where :thing_id.ne => nil }

  include Rankable

  def calculate_heat
    (1 + lovers_count + comments.count) * freezing_coefficient
  end

  need_aftermath :create, :vote

  before_save :remove_blanks

  # remove multiple <p><br></p>
  def remove_blanks
    self.content.gsub!(/(<p><br><\/p>)+\z/, "")
  end

end
