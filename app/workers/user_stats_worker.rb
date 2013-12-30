class UserStatsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    user.things_count = Thing.where(author: user).size
    user.reviews_count = Review.where(author: user).size

    orders = Order.where(user: user).where(:state.in => [:confirmed, :shipped])
    user.orders_count = orders.size
    user.expenses_count = orders.map(&:price).reduce(&:+)

    user.save!
  end
end
