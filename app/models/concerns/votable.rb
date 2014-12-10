module Votable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :lovers, class_name: "User", inverse_of: nil
    field :lovers_count, type: Integer, default: 0
    index lovers_count: -1
  end

  def voted?(user)
    lovers.include?(user)
  end

  def vote(user)
    return if voted?(user)
    lovers << user
    self.set(lovers_count: lovers.count)
  end

  def unvote(user)
    return unless voted?(user)
    lovers.delete(user)
    self.set(lovers_count: lovers.count)
  end
end
