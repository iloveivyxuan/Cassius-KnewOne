module Votable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
    has_and_belongs_to_many :foes, class_name: "User", inverse_of: nil
    field :lovers_count, type: Integer, default: 0
    index lovers_count: -1
  end

  def voted?(user)
    lovers.include?(user) or foes.include?(user)
  end

  def vote(user, love = true)
    return if voted?(user)
    if love
      lovers << user
      author.inc karma: Settings.karma.post
    else
      foes << user
      author.inc karma: -Settings.karma.post
    end
    self.set(lovers_count: lovers.count)
  end

  def unvote(user, love = true)
    return unless voted?(user)
    if love
      lovers.delete(user)
      author.inc karma: -Settings.karma.post
    else
      foes.delete(user)
      author.inc karma: Settings.karma.post
    end
    self.set(lovers_count: lovers.count)
  end
end
