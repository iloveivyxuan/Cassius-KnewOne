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

  searchable_fields [:title, :visible, :group_id, :commented_at]

  mappings do
    indexes :title, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
  end

  alias_method :_as_indexed_json, :as_indexed_json
  def as_indexed_json(options={})
    Group.public.visible.where(id: group_id).exists? ? _as_indexed_json : {}
  end

  def self.search(query)
    query_options = {
      function_score: {
        query: {
          multi_match: {
            query: query,
            fields: ['title^3', 'ngram']
          }
        },
        functions: [
          {weight: 1},
          {
            gauss: {
              commented_at: {
                origin: 'now',
                scale: '30d',
                offset: '1d',
                decay: '0.5'
              }
            }
          }
        ],
        score_mode: 'sum',
        boost_mode: 'multiply'
      }
    }

    filter_options = {
      term: {
        visible: true
      }
    }

    __elasticsearch__.search(query: query_options, filter: filter_options)
  end
end
