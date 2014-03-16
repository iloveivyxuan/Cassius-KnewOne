class Review < Post
  include Aftermath

  field :score, type: Integer, default: 0
  field :is_top, type: Boolean, default: false

  belongs_to :thing, counter_cache: true

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

  default_scope -> { desc(:is_top, :lovers_count, :created_at) }

  scope :living, -> { where :thing_id.ne => nil }

  after_create :add_score
  after_update :update_score
  after_destroy :destroy_score

  after_create do
    ReviewNotificationWorker.perform_async(self.id.to_s, :fanciers, :new_review, sender_id: self.author.id.to_s)
    ReviewNotificationWorker.perform_async(self.id.to_s, :owners, :new_review, sender_id: self.author.id.to_s)
    self.thing.author.notify :new_review, context: self, sender: self.author
  end

  def vote(user, love)
    return if voted?(user)
    if love
      lovers << user
      author.inc karma: Settings.karma.review
    else
      foes << user
      author.inc karma: -Settings.karma.review
    end
    self.update_attribute :lovers_count, lovers.count
  end

  def voted?(user)
    lovers.include?(user) || foes.include?(user)
  end

  need_aftermath :create, :destroy

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
