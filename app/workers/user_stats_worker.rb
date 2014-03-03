class UserStatsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    orders = Order.where(user: user).where(:state.in => [:confirmed, :shipped])

    user.set things_count: Thing.where(author: user).size,
             reviews_count: Review.where(author: user).size,
             orders_count: orders.size,
             expenses_count: (orders.map(&:price).reduce(&:+).to_i || 0)
  end
end
