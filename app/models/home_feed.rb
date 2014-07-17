class HomeFeed
  attr_accessor :thing, :reviews, :activities

  class << self
    def create_from_activities(activities)
      feed_from_thing = {}
      feeds = []

      activities.sort_by(&:created_at).each do |a|
        thing = a.reference.is_a?(Thing) ? a.reference : a.reference.try(:thing)

        next unless thing

        if feed_from_thing[thing]
          feed_from_thing[thing].add_activity a
        else
          feed = HomeFeed.new(thing)

          if a.type != :new_thing
            feed.add_activity(Activity.new(type: :new_thing,
                                           user_id: thing.author_id,
                                           reference_union: "Thing_#{thing.id}",
                                           created_at: thing.created_at))
          end

          feed.add_activity(a)

          feed_from_thing[thing] = feed
          feeds << feed
        end
      end

      feeds
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
