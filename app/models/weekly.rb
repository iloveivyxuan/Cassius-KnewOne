class Weekly
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  embeds_many :weekly_entries, cascade_callbacks: true
  accepts_nested_attributes_for :weekly_entries, allow_destroy: true

  field :thing_list_id, type: String
  field :since_date, type: Date

  after_initialize do
    if self.new_record?
      self.since_date ||=  Date.today.last_week
      self.since_date = self.since_date.to_date.beginning_of_week
    end
  end

  def thing_list
    if self.thing_list_id_changed?
      @_thing_list = ThingList.where(:id => self.thing_list_id).first
    else
      @_thing_list ||= ThingList.where(:id => self.thing_list_id).first
    end
  end

  def until_date
    self.since_date.end_of_week
  end

  WEIGHT = {
    fancy_thing: 1,
    new_feeling: 3,
    new_review: 3,
    add_to_list: 3,
    thing_comment: 3
  }

  THING_RELATED_UNION_PREFIX = 'Thing_'.freeze
  EMPTY_STRING = ''.freeze

  def friends_hot_things_of(user, limit = 6)
    return [] if user.followings.empty?

    fetch_hot_things_by_activities user.related_activities.visible, limit
  end

  def hot_things(limit = 14)
    if self.thing_list
      self.thing_list.get_things_by_order(limit)
    else
      fetch_hot_things_by_activities(Activity, limit)
    end
  end

  def gen_weekly_hot_things_list!(user = User.find('511114fa7373c2e3180000b4'))
    list = user.thing_lists.build name: "#{self.since_date.year}年第#{self.since_date.strftime '%W'}周热门产品",
                                  description: "#{self.since_date.strftime('%Y.%m.%d')} ~ #{self.until_date.strftime('%Y.%m.%d')}"


    things = hot_things(14)
    things.each_with_index do |t, i|
      list.thing_list_items.build thing: t, order: things.size - i
    end

    if list.save!
      self.thing_list_id = list.id.to_s
      self.save!
    end
  end

  def self.generate_for_week!(since_date = Date.today.last_week)
    w = create! since_date: since_date
    w.gen_weekly_hot_things_list!
    w
  end

  private

  def fetch_hot_things_by_activities(activities, limit = 14)
    return [] if activities.empty?

    thing_ids = activities
                  .by_types(*WEIGHT.keys)
                  .since_date(self.since_date)
                  .until_date(self.until_date)
                  .group_by(&:type)
                  .values
                  .map! do |grouped|
                    grouped.inject({}) do |weight_list, activity|
                      key = [activity.source_union, activity.reference_union]
                              .select {|v| v.start_with? THING_RELATED_UNION_PREFIX}
                              .first
                      if key
                        weight_list[key] ||= 0
                        weight_list[key] += WEIGHT[activity.type]
                      end

                      weight_list
                    end
                  end
                  .reduce({}) {|result, hash| hash.merge(result) { |key, old_value, new_value| old_value + new_value } }
                  .sort_by {|k, v| v}
                  .reverse!
                  .map!(&:first)
                  .first(limit)
                  .map! {|e| e.gsub THING_RELATED_UNION_PREFIX, EMPTY_STRING}

    Thing.where(:id.in => thing_ids).to_a
  end
end
