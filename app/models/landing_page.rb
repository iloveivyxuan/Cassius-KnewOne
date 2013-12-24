# encoding: utf-8
class LandingPage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :theme, type: Symbol
  THEMES = {dark: '深色', light: '亮色'}
  validates :theme, presence: true, inclusion: {in: THEMES.keys}

  BACKGROUND_SPECIFICATIONS = [:xs_background, :sm_background, :md_background, :lg_background, :xl_background]
  VERSIONS = [:xs, :sm, :md, :lg, :xl]
  BACKGROUND_SPECIFICATIONS.each do |type|
    mount_uploader type, ImageUploader
    # validates type, presence: true
  end
  validates :xs_background, presence: true, if: -> {persisted?}

  def background_url(spec, version = :full)
    bg = send sepc
    if bg.present?
      return bg.url if spec == :full
      return bg.url(version)
    end
    # TODO: if bg is blank then recursive bigger
  end

  field :background_alt, type: String

  embeds_many :landing_page_comments
  accepts_nested_attributes_for :landing_page_comments, allow_destroy: true, reject_if: :all_blank

  field :focus, type: String
  field :focus_link, type: String

  field :published, type: Boolean, default: false
  def published=(val)
    self[:published] = (val == 'true' || val == '1' || val == true)
  end

  def self.find_for_home
    where(published: true).last
  end
end
