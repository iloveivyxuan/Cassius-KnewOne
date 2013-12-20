# encoding: utf-8
class LandingPage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :theme, type: Symbol
  THEMES = {dark: '深色', light: '亮色'}
  validates :theme, presence: true, inclusion: {in: THEMES.keys}

  BACKGROUND_SPECIFICATIONS = [:xs_background, :sm_background, :md_background, :lg_background, :xl_background]
  BACKGROUND_SPECIFICATIONS.each do |type|
    mount_uploader type, ImageUploader
    # validates type, presence: true
  end
  field :background_alt, type: String

  field :comment, type: String
  field :commentator, type: String
  mount_uploader :commentator_avatar, AvatarUploader

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
