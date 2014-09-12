class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :author, foreign_key: :user_id, class_name: 'User', inverse_of: :thing_lists, index: true
  embeds_many :thing_list_items

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String

  validates :name, presence: true, uniqueness: { scope: :author }

  alias_method :items, :thing_list_items

  include Fanciable
  fancied_as :fancied_thing_lists

  alias_method :_fancy, :fancy
  def fancy(fancier)
    return if fancied?(fancier)
    _fancy(fancier)
    self.author.notify(:fancy_list, context: self, sender: fancier, opened: true)
  end
end
