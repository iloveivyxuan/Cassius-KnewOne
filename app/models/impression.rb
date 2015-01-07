class Impression
  include Mongoid::Document
  include Ratable

  belongs_to :author, class_name: 'User', index: true
  belongs_to :thing, index: true
  has_and_belongs_to_many :tags, inverse_of: nil

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :state, type: Symbol, default: :none

  validates :state, inclusion: {in: %i(none needed owned)}
end
