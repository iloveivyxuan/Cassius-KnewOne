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

  validates :name, presence: true, uniqueness: { scope: :author }

  alias_method :items, :thing_list_items

  scope :qualified, -> { gte(fanciers_count: 1, size: 4) }
  scope :created_between, ->(from, to) { where :created_at.gt => from, :created_at.lt => to }

  include Fanciable
  fancied_as :fancied_thing_lists

  alias_method :_fancy, :fancy
  def fancy(fancier)
    return if fancied?(fancier)
    _fancy(fancier)
    self.author.notify(:fancy_list, context: self, sender: fancier, opened: true)
  end

  include Rankable

  def calculate_heat
    return -1 if size < 6
    (fanciers_count + comments_count) * freezing_coefficient
  end

  def get_things_by_order(limit = 0)
    ids = thing_list_items.map { |item| [item.order, item.thing_id] }.sort_by(&:first).reverse!.map(&:last)
    ids = ids.first(limit) if limit > 0

    Thing.where(:id.in => ids).sort_by { |thing| ids.index(thing.id.to_s) }.reverse!
  end

  before_save do
    self.background ||= ThingListBackground.first
  end
end
