module UserStatsable
  extend ActiveSupport::Concern

  included do
    after_save :refresh_user_stats
  end

  def refresh_user_stats
    (try(:author) || try(:user)).refresh_stats!
  end
end
