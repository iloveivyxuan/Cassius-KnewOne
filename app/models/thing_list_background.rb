class ThingListBackground
  include Mongoid::Document
  include Mongoid::Timestamps


  mount_uploader :image, ImageUploader
  validates :image, presence: true, file_size: {maximum: 8.megabytes}
end
