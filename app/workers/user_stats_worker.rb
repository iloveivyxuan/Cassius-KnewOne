class UserStatsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    orders = Order.where(user: user).where(:state.in => [:confirmed, :shipped])

    user.inc things_count: Thing.where(author: user).size,
             reviews_count: Review.where(author: user).size,
             order_count: orders.size,
             expenses_count: orders.map(&:price).reduce(&:+)
  end
end
