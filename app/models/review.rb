class Review < Post
  field :content, type: String, default: ""
  field :score, type: Integer, default: 0

  belongs_to :thing

  has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
  has_and_belongs_to_many :foes, class_name: "User", inverse_of: nil

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

  def vote(user, love)
    unless voted?(user)
      (love ? lovers : foes) << user
    end
  end

  def voted?(user)
    !!(lovers.find(user) || foes.find(user))
  end

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
