class Impression
  include Mongoid::Document
  include Ratable

  belongs_to :author, class_name: 'User', index: true
  belongs_to :thing, index: true
  has_and_belongs_to_many :tags, inverse_of: nil,
                          after_add: :after_add_tag,
                          after_remove: :after_remove_tag

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :state, type: Symbol, default: :none

  validates :state, inclusion: {in: %i(none needed owned)}

  before_save do
    self.score = 0 if self.state != :owned
  end

  private

  def after_add_tag(tag)
    author.set(tag_ids: [tag.id] + (author.tag_ids - [tag.id]))
    thing.add_to_set(tag_ids: tag.id)
  end

  def after_remove_tag(tag)
    unless Impression.where(author_id: author_id, tag_ids: tag.id).exists?
      author.pull(tag_ids: tag.id)
    end

    unless Impression.where(thing_id: thing_id, tag_ids: tag.id).exists?
      thing.pull(tag_ids: tag.id)
    end
  end
end
