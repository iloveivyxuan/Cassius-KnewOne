class Weekly
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  embeds_many :weekly_entries, cascade_callbacks: true
  accepts_nested_attributes_for :weekly_entries, allow_destroy: true

  field :title, type: String

  field :thing_list_id, type: String
  field :since_date, type: Date

  mount_uploader :header_image, MailerImageUploader

  after_initialize do
    if self.new_record?
      self.since_date ||= Date.today.last_week
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

  def week
    self.since_date.strftime('%W').to_i
  end

  WEIGHT = {
    fancy_thing:   1,
    new_feeling:   3,
    new_review:    3,
    add_to_list:   3,
    thing_comment: 3
  }

  THING_RELATED_UNION_PREFIX = 'Thing_'.freeze
  EMPTY_STRING               = ''.freeze

  def friends_hot_things_of(user, limit = 6)
    return [] if user.followings.empty?

    ids = fetch_hot_thing_ids_by_activities(user.related_activities.visible, limit)

    Thing.where(:id.in => ids).sort_by { |thing| ids.index(thing.id.to_s) }
  end

  def friends_hot_things_without_global_of(user, limit = 6)
    global_ids = hot_things(limit).map {|t| t.id.to_s }
    ids = (fetch_hot_thing_ids_by_activities(user.related_activities.visible, limit*2) - global_ids).take(limit)

    Thing.where(:id.in => ids).sort_by { |thing| ids.index(thing.id.to_s) }
  end

  def hot_things(limit = 14)
    if self.thing_list
      self.thing_list.things(limit)
    else
      []
    end
  end

  def gen_weekly_hot_things_list!(user = User.find('511114fa7373c2e3180000b4'), limit = 14)
    list = user.thing_lists.build name:        "#{self.since_date.year}年第#{self.week}周热门产品",
                                  description: "#{self.since_date.strftime('%Y.%m.%d')} ~ #{self.until_date.strftime('%Y.%m.%d')}"


    ids = fetch_hot_thing_ids_by_activities(Activity, limit * 3)
    things = Thing.where(:id.in => ids, :priority.gt => 0).sort_by { |thing| ids.index(thing.id.to_s) }.first(limit)
    things.each_with_index do |t, i|
      list.thing_list_items.build thing: t, order: things.size - i
    end
    list.size = things.size

    list.save!
  end

  def self.send_edm_to_users!(weekly_id)
    w = find weekly_id

    User.edm.each do |u|
      WeeklyWorker.perform_async w.id.to_s, u.id.to_s
    end
  end

  def self.generate_for_week!(since_date = Date.today.last_week)
    w = create! since_date: since_date
    w.gen_weekly_hot_things_list!
    w
  end

  private

  def fetch_hot_thing_ids_by_activities(activities, limit = 14)
    return [] if activities.empty?

    activities
      .by_types(*WEIGHT.keys)
      .since_date(self.since_date)
      .until_date(self.until_date)
      .group_by(&:type)
      .values
      .map! do |grouped|
        grouped.inject({}) do |weight_list, activity|
          key = [activity.source_union, activity.reference_union]
                  .select { |v| v.start_with? THING_RELATED_UNION_PREFIX }
                  .first
          if key
            weight_list[key] ||= 0
            weight_list[key] += WEIGHT[activity.type]
          end

          weight_list
        end
      end
      .reduce({}) { |result, hash| hash.merge(result) { |key, old_value, new_value| old_value + new_value } }
      .sort_by { |k, v| v }
      .reverse!
      .take(limit)
      .map! { |e| e[0].gsub THING_RELATED_UNION_PREFIX, EMPTY_STRING }
  end
end
