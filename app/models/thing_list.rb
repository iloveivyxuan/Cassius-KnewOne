class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps
  include Votable

  belongs_to :user, index: true
  embeds_many :thing_list_items

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String

  validates :name, presence: true, uniqueness: { scope: :user }

  def items
    thing_list_items
  end
end
