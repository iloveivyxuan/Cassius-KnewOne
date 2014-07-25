class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Votable

  field :title, type: String
  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  belongs_to :author, class_name: "User", inverse_of: :posts

  has_many :comments

  has_many :related_lotteries, class_name: "Lottery",
           inverse_of: :contributions, dependent: :delete

  has_one :entry

  index created_at: -1

  scope :from_date, ->(date) { where :created_at.gte => date.to_time.to_i }
  scope :to_date, ->(date) { where :created_at.lt => date.next_day.to_time.to_i }

  after_create :update_commented_at

  after_create do
    update_relates_counter self.author
    touch_relates_timestamp self.author
  end

  after_destroy do
    update_relates_counter self.author, -1
  end

  around_update :around_update_counter

  def update_commented_at
    update_attribute :commented_at, created_at
  end

  def cover(version = :small)
    content_photos(version).first
  end

  def content_photos(version = :small)
    self.content.scan(/<img src=\"(http:\/\/#{Settings.image_host}\/.+?)\"/).flatten.map do |src|
      src.sub(/!.*$/, "") + "!#{version}"
    end
  end

  after_destroy :cleanup_relevant_activities
  after_destroy :cleanup_relevant_notifications

  private

  def self_changed?
    self.changed_attributes.reject { |k, v| v.nil? }.any?
  end

  def update_relates_counter(author, step = 1)
    counter_field = :"#{model_name.plural}_count"

    if author.methods.include?(counter_field) && (author.send(counter_field) + step) >= 0
      author.inc counter_field => step
    end
  end

  def touch_relates_timestamp(author)
    timestamp_field = :"last_#{model_name.singular}_created_at"

    if author.methods.include?(timestamp_field)
      author.set timestamp_field => Time.now.to_i
    end
  end

  def change_activity_user(author)
    if a = Activity.by_type(:"new_#{model_name.singular}").by_reference(self).first
      a.user = author
      a.save
    end
  end

  def around_update_counter
    if self_changed? && self.author_id_changed?
      original_author = User.find(self.author_id_was)

      yield

      if original_author != self.author
        update_relates_counter self.author
        update_relates_counter original_author, -1
        touch_relates_timestamp self.author
        change_activity_user self.author
      end
    else
      yield
    end
  end

  def cleanup_relevant_activities
    union = "#{self.class.to_s}_#{id.to_s}"
    Activity.where(reference_union: union).update_all(visible: false)
    Activity.where(source_union: union).update_all(visible: false)
  end

  def cleanup_relevant_notifications
    Notification.where(context_type: self.class.to_s, context_id: id.to_s).destroy
  end
end
