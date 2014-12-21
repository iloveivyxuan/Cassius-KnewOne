class WeeklyEntry
  include Mongoid::Document

  embedded_in :weekly

  field :subject, type: String
  field :title, type: String
  field :content, type: String
  field :link, type: String

  mount_uploader :image, CoverUploader
end
