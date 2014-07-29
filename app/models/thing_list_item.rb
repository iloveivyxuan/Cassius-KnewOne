class ThingListItem
  include Mongoid::Document

  belongs_to :thing
  embedded_in :thing_list

  field :description, type: String
  field :order, type: Float, default: 0

  scope :by_order, -> { order_by(:order.asc, :created_at.desc) }

  validates :list, presence: true
  validates :thing, presence: true, uniqueness: { scope: :list }

  before_create do
    self.order = self.list.items.max(:order).to_i + 1
  end

  def list
    thing_list
  end
end
