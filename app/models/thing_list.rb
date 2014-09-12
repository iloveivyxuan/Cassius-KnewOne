class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :user, inverse_of: :thing_list, index: true
  embeds_many :thing_list_items

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String

  validates :name, presence: true, uniqueness: { scope: :user }

  def items
    thing_list_items
  end

  include Fanciable
  fancied_as :fancied_thing_lists

  alias_method :_fancy, :fancy
  def fancy(fancier)
    return if fancied?(fancier)
    _fancy(fancier)
    self.user.notify(:fancy_list, context: self, sender: fancier, opened: true)
  end
end
