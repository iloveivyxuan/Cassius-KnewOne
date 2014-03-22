class Review < Post
  include Aftermath

  field :score, type: Integer, default: 0
  field :is_top, type: Boolean, default: false

  belongs_to :thing, counter_cache: true

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

  def official_cover(version = :small)
    src = self.content.scan(/<img src=\"(.+?)\"/).try(:[], 0).try(:[], 0)
    return nil unless src.present? and src[0..23] == 'http://image.knewone.com'

    src.gsub(/!.*$/, "!#{version}")
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
