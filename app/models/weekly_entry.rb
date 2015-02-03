class WeeklyEntry
  include Mongoid::Document

  embedded_in :weekly

  field :subject, type: String
  field :title, type: String
  field :content, type: String
  field :link, type: String

  mount_uploader :image, ImageUploader

  before_validation do
    if self.link.present?
      uri = URI.parse self.link
      uri.query ||= ''
      uri.query = uri.query.split('&').push('from=weekly').uniq.join('&')

      self.link = uri.to_s
    end
  end
end
