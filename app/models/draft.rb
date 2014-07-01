class Draft
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  validates :key, presence: true

  belongs_to :user
end
