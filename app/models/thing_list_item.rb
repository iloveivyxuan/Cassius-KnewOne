class ThingListItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :thing
  embedded_in :thing_list, counter_cache: :size

  field :description, type: String
  field :order, type: Float, default: 0

  default_scope -> { desc(:order, :created_at) }

  validates :list, presence: true
  validates :thing, presence: true, uniqueness: { scope: :list }
  validates :description, length: {maximum: 140}

  before_create do
    self.order = self.list.items.max(:order).to_i + 1
  end

  after_create do
    self.thing.fancy(list.author)
  end

  alias_method :list, :thing_list
end
