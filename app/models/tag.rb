class Tag
  include Mongoid::Document
  include Mongoid::Slug

  belongs_to :category

  field :name, type: String
  slug :name, history: true

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :things

  field :things_count, type: Integer, default: 0
  before_save :update_count

  def self.find_by_sequence(name)
    return all if name.blank?
    str = Regexp.escape(name.gsub(/[^\u4e00-\u9fa5a-zA-Z0-9_-]+/, ''))
    where(name: /^#{str}/i)
  end

  def update_count
    self.things_count = self.things.size
  end
end
