module Feedable
  extend ActiveSupport::Concern

  included do
    has_one :relationship, dependent: :destroy
    has_many :activities

    field :followers_count, type: Integer, default: 0
    field :followings_count, type: Integer, default: 0

    delegate :following_ids, :followings, :follower_ids, :followers, to: :relationship

    after_create :create_relationship
  end

  def followed?(user)
    return false unless user

    if user.instance_variable_defined?('@_relationship')
      user.follower_ids.include?(self.id)
    else
      self.following_ids.include?(user.id)
    end
  end

  def follow(user)
    return if !user || user == self || followed?(user)

    self.relationship.add_to_set(following_ids: user.id)
    user.relationship.add_to_set(follower_ids: self.id)

    self.set(followings_count: self.relationship.following_ids.size)
    user.set(followers_count: user.relationship.follower_ids.size)

    user.notify :following, sender: self
  end

  def unfollow(user)
    return unless followed?(user)

    self.relationship.pull(following_ids: user.id)
    user.relationship.pull(follower_ids: self.id)

    self.set(followings_count: self.relationship.following_ids.size)
    user.set(followers_count: user.relationship.follower_ids.size)
  end

  def batch_follow(users)
    users.each { |u| follow u }
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

  def related_activities
    user_ids = following_ids + [self.id]
    Activity.where(:user_id.in => user_ids)
  end
end
