class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Votable
  include AutoCleanup

  field :title, type: String

  validate :title_cannot_include_reserved_words
  def title_cannot_include_reserved_words
    return if self.title.blank?

    if Blacklist.all.map(&:word).any? { |word| title.downcase.include? word }
      errors.add(:title, '名字不和谐')
    end
  end

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

  before_save :format_title
  before_save :remove_ending_blanks

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

  private

  def self_changed?
    self.changed_attributes.reject { |k, v| v.nil? }.any?
  end

  def format_title
    if self.title.present?
      self.title = self.title.
        gsub(/(?<=[0-9a-z])(?=[\u4e00-\u9fa5])/i, ' ').
        gsub(/(?=[0-9a-z])(?<=[\u4e00-\u9fa5])/i, ' ')
    end
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
    if self_changed? &&
      self.author_id_changed? &&
      self.author_id_was.present? &&
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

  # remove multiple <p><br></p>
  def remove_ending_blanks
    self.content.gsub!(/(<p><br><\/p>)+\z/, "")
    self.content = "<p><br></p>" if self.content.empty?
  end
end
