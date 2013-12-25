class Review < Post
  field :score, type: Integer, default: 0
  field :is_top, type: Boolean, default: false

  # TODO: remove in future
  belongs_to :thing

  belongs_to :thing_group
  before_create do
    unless self.thing.thing_group
      self.thing.build_thing_group(founder: self.thing.author, name: self.thing.title).save
    end

    self.thing_group = self.thing.thing_group
  end


  has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
  has_and_belongs_to_many :foes, class_name: "User", inverse_of: nil
  field :lovers_count, type: Integer, default: 0

  validates :score, presence: true
  validate do |review|
    unless (0..5).include? review.score
        errors.add(:score,
                   "Score should be in [0..5]")
    end
  end

  default_scope desc(:is_top, :lovers_count, :created_at)

  after_create :add_score
  after_update :update_score
  after_destroy :destroy_score

  def vote(user, love)
    return if voted?(user)
    if love
      lovers << user
      author.inc karma: Settings.karma.review
    else
      foes << user
      author.inc karma: -Settings.karma.review
    end
  end

  def voted?(user)
    lovers.include?(user) || foes.include?(user)
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
