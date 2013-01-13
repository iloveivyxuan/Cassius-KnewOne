class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :size, type: Integer
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :photographic, polymorphic: true

  attr_accessible :name, :image, :user

  validates :image, presence: true

  delegate :url, to: :image

  before_create :set_attributes

  def set_attributes
    if image
      self.name ||= image.file.original_filename
      self.size ||= image.file.size
    end
  end

  def to_jq_upload
    {
      "id" => id.to_s,
      "name" => name,
      "size" => size,
      "url" => url
    }
  end

end
