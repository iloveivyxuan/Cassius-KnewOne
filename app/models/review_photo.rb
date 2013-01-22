class ReviewPhoto
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :image, ImageUploader

  validates :image,
  presence: true,
  file_size: {maximum: 8.megabytes.to_i}

  delegate :url, to: :image

  def to_json
    {
      "filelink" => url(:huge)
    }
  end

end
