class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :published, type: Boolean, default: false

  mount_uploader :cover, ImageUploader

  BACKGROUND_SPECIFICATIONS = [:small_cover, :medium_cover, :large_cover, :larger_cover]
  BACKGROUND_SPECIFICATIONS.each do |type|
    mount_uploader type, ImageUploader
    # validates type, presence: true
  end

  def background_url(spec, version = :full)
    bg = send :"#{spec}_cover"
    if bg.present?
      return bg.url if version == :full
      return bg.url(version)
    end
    # TODO: if bg is blank then recursive bigger
  end

  belongs_to :user, inverse_of: nil
  field :note, type: String
  field :link, type: String

  default_scope -> { desc(:created_at) }
  scope :published, -> { where published: true }

  def self.newest
    published.first
  end
end
