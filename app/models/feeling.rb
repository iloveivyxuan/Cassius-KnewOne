class Feeling < Post
  include Ratable
  include Atable
  include Aftermath

  field :photo_ids, type: Array, default: []

  validates :content, presence: true, length: { maximum: 140 }

  belongs_to :thing, index: true, counter_cache: true

  def photos
    Photo.find_with_order photo_ids
  end

  def cover
    begin
      return Photo.new if photo_ids.blank?
      Photo.find photo_ids.first
    rescue Mongoid::Errors::DocumentNotFound
      Photo.new
    end
  end

  def notify_by(user, content_users)
    content_users.each do |u|
      u.notify :feeling, context: self, sender: user, opened: false
    end

    thing.author.notify :new_feeling, context: self, sender: user, opened: false

    user.log_activity :new_feeling, self, source: thing
  end

  need_aftermath :vote
end
