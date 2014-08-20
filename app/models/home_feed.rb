class HomeFeed
  attr_accessor :thing, :reviews, :activities, :updated_at

  class << self
    def create_from_activities(activities)
      activities.uniq do |a|
        [a.type, a.relate_thing, a.user]
      end.reduce({}) do |feeds, a|
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

    def create_from_things_and_reviews(things, reviews)
      feeds = things.map { |thing| HomeFeed.new thing }
      reviews.each do |review|
        feed = feeds.find { |f| f.thing == review.thing }
        unless feed
          feed = HomeFeed.new review.thing
          feeds.insert rand(feeds.length), feed
        end
        feed.reviews << review
      end
      feeds
    end
  end

  def initialize(thing)
    @thing = thing
    @reviews = []
    @activities = []
  end

  def author
    @author ||= if @activities.present?
                  @activities.first.user
                else
                  @thing.author
                end
  end

  def add_activity(activity)
    if activity.reference.is_a? Review
      review = activity.reference
      @reviews << review unless @reviews.include?(review)
    end

    return if activity.type == :fancy_thing && @activities.any? { |a| a.type == :add_to_list }

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
