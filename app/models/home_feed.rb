class HomeFeed
  attr_accessor :thing, :reviews, :activities

  class << self
    def create_from_activities(activities)
      activities.sort_by(&:created_at).reduce([]) do |feeds, a|
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
    @reviews = []
    @activities = []
    activities.each(&method(:add_activity))
  end

  def add_activity(activity)
    if activity.reference.is_a? Review
      review = activity.reference
      @reviews << review unless @reviews.include?(review)
    end

    @activities << activity
  end

  def activities_not_from_reviews
    @activities.reject { |a| a.reference.is_a? Review }
  end

  def activities_from(reference)
    @activities.select { |a| a.reference == reference }
  end
end
