class Review < Post
  field :content, type: String, default: ""
  field :score, type: Integer, default: 0

  belongs_to :thing

  validates :content, presence: true
  validates :score, presence: true
  validate do |review|
    unless (0..5).include? review.score
        errors.add(:score,
                   "Score should be in [0..5]")
    end
  end

  after_create :add_score
  after_update :update_score
  after_destroy :destroy_score

  private

  def add_score
    thing.add_score score
  end

  def update_score
    if score_changed?
      thing.del_score changed_attributes["score"]
      thing.add_score score
    end
  end

  def destroy_score
    thing.del_score score
  end

end
