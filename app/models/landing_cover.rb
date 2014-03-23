# encoding: utf-8
class LandingCover
  include Mongoid::Document
  include Mongoid::Timestamps

  #field :theme, type: Symbol
  #THEMES = {dark: '深色', light: '亮色'}
  #validates :theme, presence: true, inclusion: {in: THEMES.keys}

  mount_uploader :cover, ImageUploader
  validates :cover, presence: true

  field :published, type: Boolean, default: false

  def published=(val)
    self[:published] = (val == 'true' || val == '1' || val == true)
  end

  default_scope -> { desc :created_at }

  def self.find_for_home
    where(published: true).first
  end
end
