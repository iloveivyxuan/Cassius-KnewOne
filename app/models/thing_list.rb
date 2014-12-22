class ThingList
  include Mongoid::Document
  include Mongoid::Timestamps
  include AutoCleanup

  belongs_to :author, class_name: 'User', inverse_of: :thing_lists, index: true
  embeds_many :thing_list_items
  has_many :comments
  belongs_to :background, class_name: 'ThingListBackground', index: true

  index 'thing_list_items.thing_id' => 1

  field :name, type: String
  field :description, type: String
  field :size, type: Integer, default: 0

  validates :name, presence: true, uniqueness: { scope: :author }

  alias_method :items, :thing_list_items

  scope :qualified, -> { gte(fanciers_count: 1, size: 4) }

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
    (fanciers_count + comments.count) * freezing_coefficient
  end

  before_save do
    self.background ||= ThingListBackground.first
  end

  def self.generate_hot_thing_for_weekly(since_date = Date.today - 7.days, user = User.find('511114fa7373c2e3180000b4'), limit = 6)
    due_date = since_date + 6.days
    list = user.thing_lists.build name: "店长推荐（#{since_date.strftime('%Y.%m.%d')} ~ #{due_date.strftime('%Y.%m.%d')}）"

    Thing.hot.from_date(since_date).to_date(due_date).limit(limit).each_with_index do |t, i|
      list.thing_list_items.build thing: t, order: i.to_f
    end

    list.save
  end
end
