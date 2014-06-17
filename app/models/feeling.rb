class Feeling < Post
  include Rateable
  include Atable
  include Aftermath

  field :photo_ids, type: Array, default: []

  belongs_to :thing, counter_cache: true, index: true

  validates :content, presence: true, length: { maximum: 140 }

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

  include Rankable

  def calculate_heat
    (1 + lovers_count + comments.count) * freezing_coefficient
  end

  need_aftermath :vote
end
