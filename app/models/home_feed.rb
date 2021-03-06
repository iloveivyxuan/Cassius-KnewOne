class HomeFeed
  attr_accessor :subject, :thing, :thing_list, :reviews, :activities, :updated_at

  class << self
    def create_from_activities(activities)
      Activity.eager_load!(activities)

      activities.uniq do |a|
        [a.type, a.related_thing, a.related_thing_list, a.user_id]
      end.reduce({}) do |feeds, a|
        subject = a.related_thing || a.related_thing_list
        if feeds[subject]
          feeds[subject].add_activity a
        elsif subject
          feed = HomeFeed.new subject
          feed.add_activity a
          feeds[subject] = feed
        end
        feeds
      end.values.sort_by(&:updated_at).reverse
    end
  end

  def initialize(subject)
    case subject
    when Thing
      @thing = subject
    when ThingList
      @thing_list = subject
    else
      raise "Unknown subject: #{subject}"
    end

    @subject = subject
    @reviews = []
    @activities = []
  end

  def author_id
    @activities.present? ? @activities.first.user_id : @thing.author_id
  end

  def add_activity(activity)
    if activity.reference.is_a? Review
      review = activity.reference
      @reviews << review unless @reviews.include?(review)
    end

    return if activity.type == :fancy_thing && @activities.any? { |a| [:desire_thing, :own_thing].include?(a.type) }
    return if activity.type == :desire_thing && @activities.any? { |a| a.type == :own_thing }

    @activities << activity
    unless updated_at and activity.created_at < updated_at
      self.updated_at = activity.created_at
    end
  end

  def activities_not_from_reviews(type = nil)
    @activities.reject { |a| (!type || a.type == type) && a.reference.is_a?(Review) }
  end

  def activities_from(reference, type = nil)
    @activities.select { |a| (!type || a.type == type) && a.reference == reference }
  end
end
