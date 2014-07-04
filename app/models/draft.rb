class Draft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  validates :key, presence: true

  field :content, type: String, default: ''

  belongs_to :user

  def hoist_content
    h = JSON.parse(content) rescue {}
    h.merge(attributes.except('content'))
  end
end
