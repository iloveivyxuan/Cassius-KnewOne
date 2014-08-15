module Haven
  class StatsController < ApplicationController
    layout 'settings'

    def index
    end

    def new
      @date_from = Date.new(params["date"]["from(1i)"].to_i, params["date"]["from(2i)"].to_i, params["date"]["from(3i)"].to_i)
      @date_to = Date.new(params["date"]["to(1i)"].to_i, params["date"]["to(2i)"].to_i, params["date"]["to(3i)"].to_i)
      @stat = Stat.new
      Stat::DATAS.keys.each { |key| @stat[key] = self.send(key) if self.respond_to?(key) }
    end

    def create
      group = Group.find("53ed7b6b31302d5e7b9d0900")
      @stat = Stat.new stat_params
      content = ""
      Stat::DATAS.keys.each do |key|
        content += "<b>#{Stat::DATAS[key]}</b>"
        if Stat::BUNCH_DATAS.include? key
          JSON.parse(@stat[key]).each do |s|
            content += "<div>#{s.first} | #{s.last} </div>"
          end
        else
          content += "<div>#{@stat[key]}</div>"
        end
      end
      if @stat.date_from == @stat.date_to
        title = "#{@stat.date_to} 数据"
      else
        title = "#{@stat.date_from} - #{@stat.date_to} 数据"
      end
      @topic = Topic.create(
                            title: title,
                            content: content,
                            author: current_user,
                            group: group,
                            visible: false)
      redirect_to group_topic_url(group, @topic)
    end

    def users_count
      User.all.size
    end

    def login_activities
      Activity.by_type(:login_user).from_date(@date_from).to_date(@date_to)
    end

    def login_users
      # login_activities.map(&:user).uniq!.size
    end

    def user_logins
      # login_activities.size
    end

    def activities_users
      Activity.from_date(@date_from).to_date(@date_to).all.map(&:user).uniq!.size
    end

    def all_follows
      Activity.by_type(:follow_user).from_date(@date_from).to_date(@date_to)
    end

    def ave_follows_count
      all_uniq_users = all_follows.map(&:user).uniq!
      all_follows.size / all_uniq_users.size
    end

    def ave_followers_count
      all_uniq_users = all_follows.map(&:reference).uniq!
      all_follows.size / all_uniq_users.size
    end

    def all_likes
      Activity.by_type(:fancy_thing).from_date(@date_from).to_date(@date_to)
    end

    def likes_count
      all_likes.size
    end

    def product_likes_tops
      things = all_likes.map(&:reference)
      uniqs = things.uniq.compact
      Hash[uniqs.map { |v| [v.title, things.count(v)] }].sort_by { |_, value| value }.reverse.take(10)
    end

    def all_plus_one
      Activity.where(:type.in => [:love_review, :love_feeling, :love_topic]).from_date(@date_from).to_date(@date_to)
    end

    def plus_one_count
      all_plus_one.size
    end

    def plus_one_tops
      plus_ones = all_plus_one.map(&:reference)
      uniqs = plus_ones.uniq.compact
      Hash[uniqs.map { |v| [v.title, plus_ones.count(v)] }].sort_by { |_, value| value }.reverse.take(10)
    end

    def all_feelings
      Activity.by_type(:new_feeling).from_date(@date_from).to_date(@date_to)
    end

    def feelings_count
      all_feelings.size
    end

    def product_feelings_tops
      things = all_feelings.map(&:source)
      uniq_things = things.uniq.compact
      Hash[uniq_things.map { |v| [v.title, things.count(v)] }].sort_by { |_, value| value }.reverse.take(10)
    end

    def all_reviews
      Activity.by_type(:new_review).from_date(@date_from).to_date(@date_to)
    end

    def reviews_count
      all_reviews.size
    end

    def product_reviews_tops
      things = all_reviews.map(&:source)
      uniq_things = things.uniq.compact
      Hash[uniq_things.map { |v| [v.title, things.count(v)] }].sort_by { |_, value| value }.reverse.take(10)
    end

    def new_things
      Activity.by_type(:new_thing).from_date(@date_from).to_date(@date_to).map(&:reference)
    end

    def products_count
      new_things.size
    end

    def has_link_products_count
      new_things.compact.select { |t| t.shop != "" }.size
    end

    def dsell_products_count
      new_things.compact.select { |t| t.shop != "" }.size
    end

    def has_reviews_products_count
      new_things.compact.select { |t| t.reviews != [] }.size
    end

    def all_orders
      Order.where(:state.in => [:confirmed, :shipped]).from_date(@date_from).to_date(@date_to)
    end

    def sale_sum
      all_orders.map(&:trade_price).select { |p| !p.nil? }.reduce(&:+)
    end

    def orders_count
      all_orders.size
    end

    def orders_users_count
      Order.from_date(a).to_date(a).map(&:user).uniq.size
    end

    def per_customer_sales
      sale_sum / orders_users_count
    end

    def all_order_items
      items = []
      all_orders.each { |o| items += o.order_items }
      items
    end

    def most_sales_product
      # todo
    end

    def less_sales_product
      # todo
    end

    def has_purchased_users_count
      all_orders.map(&:user).uniq.size
    end

    def ave_purchased_price
      # todo
    end

    private

    def stat_params
      params.require(:stat).permit(Stat::DATAS.keys + [:date_from, :date_to, :note])
    end

  end
end
