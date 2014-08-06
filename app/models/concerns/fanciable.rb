module Fanciable
  extend ActiveSupport::Concern

  included do
    field :fanciers_count, type: Integer, default: 0
    index fanciers_count: -1
  end

  def fancy(user)
    return if fancied?(user)

    self.push(fancier_ids: user.id)
    user.push(fancy_ids: self.id)

    update_attribute :fanciers_count, fanciers.count

    reload
    user.reload

    user.inc karma: Settings.karma.fancy
  end

  def unfancy(user)
    return unless fancied?(user)
    fanciers.delete user
    user.fancies.delete self
    update_attribute :fanciers_count, fanciers.count
    user.inc karma: -Settings.karma.fancy
  end

  def fancied?(user)
    fanciers.include? user
  end
end
