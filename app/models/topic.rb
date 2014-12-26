class Topic < Post
  include Aftermath

  field :is_top, type: Boolean, default: false

  belongs_to :group, counter_cache: true, index: true

  validates :title, presence: true
  validates :content, presence: true

  field :visible, type: Boolean, default: true
  scope :visible, -> { where visible: true }

  field :approved, type: Boolean, default: false
  scope :approved, -> { where approved: true }

  need_aftermath :vote

  before_save :update_approved

  def update_approved
    return unless self.group.approved
    self.approved = true
  end

  include Searchable

  searchable_fields [:title]

  mappings do
    indexes :title, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
  end

  def self.search(query)
    query_options = {
      multi_match: {
        query: query,
        fields: ['title^3', 'ngram']
      }
    }

    __elasticsearch__.search(query: query_options)
  end
end
