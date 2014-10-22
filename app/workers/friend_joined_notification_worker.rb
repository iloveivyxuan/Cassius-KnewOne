class FriendJoinedNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications

  def perform(user_id)
    user = User.find user_id
    #TODO: Just support Weibo fridend
    if friends = user.recommend_users(true)
      friends.each do |f|
        f.notify :weibo_friend_joined, context: user, opened: true
      end
    end
  end
end
