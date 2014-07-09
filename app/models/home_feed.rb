class HomeFeed
  attr_accessor :thing, :activities

  class << self
    def create_from_activities(activities)
      activities.reduce([]) do |feeds, a|
        thing = a.reference.is_a?(Thing) ? a.reference : a.reference.try(:thing)
        if index = feeds.find_index {|f| f.thing == thing}
          feeds[index].add_activity a
        elsif thing
          feeds << HomeFeed.new(thing, [a])
        end
        feeds
      end
    end
  end

  def initialize(thing, activities=[])
    @thing = thing
    @activities = activities
  end

  def add_activity(activity)
    @activities << activity
  end
end
