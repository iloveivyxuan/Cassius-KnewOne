class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :note, type: String
  field :link, type: String
  field :published, type: Boolean, default: false

  mount_uploader :cover, ImageUploader

  default_scope -> { desc(:created_at) }
  scope :published, -> { where published: true }
end
