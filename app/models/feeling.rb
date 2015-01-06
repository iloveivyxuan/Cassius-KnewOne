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

  need_aftermath :vote
end
