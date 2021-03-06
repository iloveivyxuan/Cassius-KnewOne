module Votable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
    field :lovers_count, type: Integer, default: 0
    index lovers_count: -1
  end

  def voted?(user)
    user && lover_ids.include?(user.id)
  end

  def vote(user)
    return if voted?(user) || !user

    self.add_to_set(lover_ids: user.id)
    self.set(lovers_count: lover_ids.count)
    self.touch

    author.inc karma: karma_to_bump_from_loving
  end

  def unvote(user)
    return unless voted?(user)

    self.pull(lover_ids: user.id)
    self.set(lovers_count: lover_ids.count)
    self.touch

    author.inc karma: -karma_to_bump_from_loving
  end

  def karma_to_bump_from_loving
    Settings.karma.love[self.class.to_s.underscore] || 0
  end
end
