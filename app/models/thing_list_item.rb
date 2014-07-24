class ThingListItem
  include Mongoid::Document

  belongs_to :thing
  embedded_in :thing_list

  field :description, type: String

  validates :list, presence: true
  validates :thing, presence: true, uniqueness: { scope: :list }

  def list
    thing_list
  end
end
