class Jumptron
  include Mongoid::Document
  include Mongoid::Timestamps

  field :alt, type: String
  field :href, type: String
  field :default, type: Boolean, default: false

  mount_uploader :image, ImageUploader

  validates :image, presence: true, file_size: {maximum: 8.megabytes.to_i}

end
