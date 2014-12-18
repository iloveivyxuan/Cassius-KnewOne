class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :note, type: String
  field :link, type: String
  field :published, type: Boolean, default: false
  field :priority, type: Integer, default: 0

  mount_uploader :cover, ImageUploader

  scope :published, -> { where published: true }
end
