class HomeFeed
  attr_accessor :thing, :reviews, :activities, :updated_at

  class << self
    def create_from_activities(activities)
      activities.sort_by(&:created_at).reduce({}) do |feeds, a|
        thing = a.relate_thing
        if feeds[thing]
          feeds[thing].add_activity a
        elsif thing
          feed = HomeFeed.new thing
          feed.add_activity a
          feeds[thing] = feed
        end
        feeds
      end.values.sort_by(&:updated_at).reverse
    end
  end

  def initialize(thing)
    @thing = thing
    @reviews = []
    @activities = []
  end

  def add_activity(activity)
    if activity.reference.is_a? Review
      review = activity.reference
      @reviews << review unless @reviews.include?(review)
    end

    @activities << activity
    unless updated_at and activity.created_at < updated_at
      self.updated_at = activity.created_at
    end
  end

  def activities_not_from_reviews
    @activities.reject { |a| a.reference.is_a? Review }
  end

  def activities_from(reference)
    @activities.select { |a| a.reference == reference }
  end
end
