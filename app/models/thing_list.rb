class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :author, class_name: 'User', inverse_of: :thing_lists, index: true
  embeds_many :thing_list_items

  has_many :comments
  field :comments_count, type: Integer, default: 0

  belongs_to :background, class_name: 'ThingListBackground', index: true

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String
  field :size, type: Integer, default: 0

  validates :name, presence: true, uniqueness: {scope: :author}, length: {maximum: 60}
  validates :description, length: {maximum: 300}

  alias_method :items, :thing_list_items

  scope :qualified, -> { gte(fanciers_count: 1, size: 4) }
  scope :created_between, ->(from, to) { where :created_at.gt => from, :created_at.lt => to }

  def sort_items(sort_options = {created_at: :desc})
    items.unscoped.order_by(sort_options).each_with_index do |item, i|
      item.order = size - i
    end
  end

  include Fanciable
  fancied_as :fancied_thing_lists

  alias_method :_fancy, :fancy
  def fancy(fancier)
    return if fancied?(fancier)
    _fancy(fancier)
    author.notify(:fancy_list, context: self, sender: fancier, opened: true)
  end

  include Rankable

  def calculate_heat
    return -1 if size < 6
    (fanciers_count + comments_count) * freezing_coefficient
  end

  def things(limit = nil)
    ids = thing_list_items.pluck(:thing_id)
    ids = ids.take(limit) if limit

    Thing.in(id: ids).sort_by { |thing| ids.index(thing.id) }
  end

  def full?
    size >= 300
  end

  include Searchable

  searchable_fields [:name, :size, :fanciers_count, :updated_at]

  mappings do
    indexes :name, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
  end

  def self.search(query)
    query_options = {
      function_score: {
        query: {
          multi_match: {
            query: query,
            fields: ['name^3', 'ngram']
          }
        },
        field_value_factor: {
          field: 'fanciers_count',
          modifier: 'log2p'
        }
      }
    }

    filter_options = {
      range: {
        fanciers_count: {gte: 1},
        size: {gte: 4}
      }
    }

    __elasticsearch__.search(query: query_options, filter: filter_options)
  end

  before_save do
    self.background ||= ThingListBackground.first
  end
end
