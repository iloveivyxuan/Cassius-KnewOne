class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :size, type: Integer
  mount_uploader :image, ImageUploader

  attr_accessible :name, :image, :user
  validates :image, presence: true
  belongs_to :user
  delegate :url, to: :image

  before_create :set_attributes

  def set_attributes
    if image
      self.name ||= image.file.original_filename
      self.size ||= image.file.size
    end
  end
end
