class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :size, type: Integer
  mount_uploader :photo, PhotoUploader

  attr_accessible :name, :photo
  validates :photo, presence: true
  belongs_to :user
  delegate :url, to: :photo

  before_create :set_attributes

  def set_attributes
    if photo
      self.name ||= photo.file.original_filename
      self.size ||= photo.file.size
    end
  end
end
