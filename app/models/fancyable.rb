module Fancyable
  extend ActiveSupport::Concern

  included do
    field :fanciers_count, type: Integer, default: 0
  end

  def fancy(user)
    return if fancied?(user)
    fanciers << user
    update_attribute :fanciers_count, fanciers.count
    user.inc karma: Settings.karma.fancy
  end

  def unfancy(user)
    return unless fancied?(user)
    fanciers.delete user
    update_attribute :fanciers_count, fanciers.count
    user.inc karma: -Settings.karma.fancy
  end

  def fancied?(user)
    fanciers.include? user
  end
end
