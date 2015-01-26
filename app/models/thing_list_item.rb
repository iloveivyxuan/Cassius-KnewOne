class ThingListItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :thing
  embedded_in :thing_list, counter_cache: :size, touch: true

  field :description, type: String
  field :order, type: Float, default: 0

  default_scope -> { desc(:order, :created_at) }

  validates :thing_id, presence: true, uniqueness: { scope: :thing_list }
  validates :description, length: {maximum: 140}

  before_create do
    self.order = self.list.items.max(:order).to_i + 1
  end

  alias_method :list, :thing_list
end
