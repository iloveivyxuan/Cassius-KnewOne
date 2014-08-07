class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, index: true
  embeds_many :thing_list_items

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String

  validates :name, presence: true, uniqueness: { scope: :user }

  def items
    thing_list_items
  end

  include Fanciable
  has_and_belongs_to_many :fanciers, class_name: 'User', inverse_of: :fancied_thing_lists

  def fancy(user)
    return if fancied?(user)

    self.push(fancier_ids: user.id)
    user.push(fancied_thing_list_ids: self.id)

    update_attribute :fanciers_count, fanciers.count

    reload
    user.reload

    user.inc karma: Settings.karma.fancy
  end

  def unfancy(user)
    return unless fancied?(user)
    fanciers.delete user
    user.fancied_thing_lists.delete self
    update_attribute :fanciers_count, fanciers.count
    user.inc karma: -Settings.karma.fancy
  end
end
