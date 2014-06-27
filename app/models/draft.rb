class Draft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  validates :key, presence: true

  field :content, type: String, default: ''

  belongs_to :user
end
