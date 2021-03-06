class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :size, type: Integer
  mount_uploader :image, ImageUploader

  belongs_to :user

  validates :image,
            presence: true,
            file_size: {maximum: 8.megabytes.to_i}

  delegate :url, to: :image

  before_create :set_attributes

  class << self
    def find_with_order(ids)
      photos = Photo.where(:id.in => ids.uniq)
      photos.sort_by {|t| ids.index(t.id.to_s)}
    end
  end

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
        "small_url" => url(:small),
        "url" => url,
        "filelink" => url
    }
  end
end
