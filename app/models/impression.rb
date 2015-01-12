class Impression
  include Mongoid::Document
  include Ratable

  belongs_to :author, class_name: 'User', index: true
  belongs_to :thing, index: true
  has_and_belongs_to_many :tags, inverse_of: nil,
                          before_add: :before_add_tag,
                          before_remove: :before_remove_tag

  validates :author, presence: true
  validates :thing, presence: true, uniqueness: {scope: :author}

  field :description, type: String, default: ''
  field :state, type: Symbol, default: :none

  validates :state, inclusion: {in: %i(none desired owned)}

  before_save do
    self.score = 0 if self.state != :owned
  end

  private

  def before_add_tag(tag)
    author.set(tag_ids: [tag.id] + (author.tag_ids - [tag.id]))
    thing.add_to_set(tag_ids: tag.id)
  end

  def before_remove_tag(tag)
    if Impression.where(author_id: author_id, tag_ids: tag.id).count <= 1
      author.pull(tag_ids: tag.id)
    end

    if Impression.where(thing_id: thing_id, tag_ids: tag.id).count <= 1
      thing.pull(tag_ids: tag.id)
    end
  end
end
