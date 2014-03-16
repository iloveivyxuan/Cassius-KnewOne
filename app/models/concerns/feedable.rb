module Feedable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :followings, class_name: 'User', inverse_of: :followers
    has_and_belongs_to_many :followers, class_name: 'User', inverse_of: :followings

    has_many :activities
  end

  def followings_activities
    Activity.by_users(self.followings)
  end

  def log_activity(type, reference = nil, options = {})
    activity = self.activities.build({type: type}.merge(options))
    activity.reference = reference
    activity.save
  end
end
