# -*- coding: utf-8 -*-
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  belongs_to :author, class_name: "User", inverse_of: :posts

  has_many :comments

  has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
  has_and_belongs_to_many :foes, class_name: "User", inverse_of: nil
  field :lovers_count, type: Integer, default: 0

  has_many :related_lotteries, class_name: "Lottery",
           inverse_of: :contributions, dependent: :delete

  index created_at: -1

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

  def vote(user, love)
    return if voted?(user)
    if love
      lovers << user
      author.inc karma: Settings.karma.post
    else
      foes << user
      author.inc karma: -Settings.karma.post
    end
    self.update_attribute :lovers_count, lovers.count
  end

  def unvote(user, love)
    return unless voted?(user)
    if love
      lovers.delete(user)
      author.inc karma: -Settings.karma.post
    else
      foes.delete(user)
      author.inc karma: Settings.karma.post
    end
    self.update_attribute :lovers_count, lovers.count
  end

  def voted?(user)
    lovers.include?(user) or foes.include?(user)
  end

  def cover(version = :small)
    content_photos(version).first
  end

  def content_photos(version = :small)
    self.content.scan(/<img src=\"(http:\/\/#{Settings.image_host}\/.+?)\"/).flatten.map do |src|
      src.sub(/!.*$/, "!#{version}")
    end
  end

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

  def around_update_counter
    if self_changed? && self.author_id_changed?
      original_author = User.find(self.author_id_was)

      yield

      if original_author != self.author
        update_relates_counter self.author
        update_relates_counter original_author, -1
        touch_relates_timestamp self.author
      end
    else
      yield
    end
  end
end
