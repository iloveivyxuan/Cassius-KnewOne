class Weekly
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  embeds_many :weekly_entries, cascade_callbacks: true
  accepts_nested_attributes_for :weekly_entries, allow_destroy: true

  field :thing_list_id, type: String
  field :since_date, type: Date, default: (Date.today - 7.days)

  def thing_list
    if self.thing_list_id_changed?
      @_thing_list = ThingList.where(:id => self.thing_list_id).first
    else
      @_thing_list ||= ThingList.where(:id => self.thing_list_id).first
    end
  end

  def due_date
    if self.since_date_changed?
      @_due_date = self.since_date + 6.days
    else
      @_due_date ||= self.since_date + 6.days
    end
  end

  def friends_hot_things_of(user, limit = 6)
    thing_ids = user
                .related_activities(%i(fancy_thing))
                .from_date(self.since_date)
                .to_date(self.due_date)
                .map(&:reference_union)
                .group_by { |e| e }
                .values
                .sort_by! { |e| e.size }
                .reverse!
                .first(limit)
                .map! {|e| e[0].gsub 'Thing_', ''}
    Thing.where :id.in => thing_ids
  end

  def hot_things(limit = 6)
    thing_ids = thing_list.thing_list_items.limit(limit).map(&:thing_id)
    Thing.where :id.in => thing_ids
  end
end
