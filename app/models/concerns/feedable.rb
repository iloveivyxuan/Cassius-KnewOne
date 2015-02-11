module Feedable
  extend ActiveSupport::Concern

  included do
    has_one :relationship, dependent: :destroy
    has_many :activities

    delegate :following_ids, :followings, :follower_ids, :followers, to: :relationship

    after_create :create_relationship
  end

  def followings_activities
    Activity.by_users(self.followings)
  end

  def log_activity(type, reference = nil, options = {})
    if options.delete :check_recent
      recent_activity = self.activities.first
      return false if !!recent_activity && recent_activity.type == type && recent_activity.reference == reference
    end
    source = options.delete :source

    activity = self.activities.build({type: type}.merge(options))
    activity.reference = reference
    activity.source = source || reference

    activity.save
  end
end
