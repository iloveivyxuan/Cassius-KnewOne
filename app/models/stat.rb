class Stat
  include Mongoid::Document
  include Mongoid::Timestamps

  DATAS = {
    # 用户相关
    :users_count => '新增用户',
    :users_total_count => '总用户数',
    :login_users => '登录用户数量',
    :user_logins => '用户登录次数',
    :activities_users => '有交互用户数',
    :ave_follows_count => '用户平均关注数量',
    :ave_followers_count => '用户平均被关注数量',
    # 交互数据
    :likes_count => '总 like 数',
    :product_likes_tops => '分产品 like 数前 10',
    :plus_one_count => '总赞数',
    :reviews_plus_tops => '评测赞数前 10',
    :feelings_count => '短评数',
    :product_feelings_tops => '分产品短评数前 10',
    :reviews_count => '评测数',
    :product_reviews_tops => '分产品评测数前 10',
    :new_products_count => '新产品数',
    :buy_clicks => '购买按钮点击数量',
    :product_buy_clicks_tops => '分产品购买按钮点击数前 10',
    # 产品相关
    :products_count => '产品数',
    :has_link_products_count => '有购买链接产品数',
    :dsell_products_count => '自营产品数',
    :has_reviews_products_count => '有评测的产品数',
    :groundbreaking_reviews_products_count => '突破 0 评测的产品数',
    # 销售
    :sale_sum => '销售额',
    :orders_count => '订单数',
    :orders_users_count => '下单的用户数',
    :per_customer_sales => '客单价',
    :most_sales_product => '销售最多的产品',
    :less_sales_product => '销售最少的产品',
    :has_purchased_users_count => '消费过的用户数'
  }

  # datas with text_area
  BUNCH_DATAS = [
                 :product_likes_tops,
                 :reviews_plus_tops,
                 :product_feelings_tops,
                 :product_reviews_tops
                ]

  # datas which need manual input
  MANUAL_INPUT_DATAS = [
                        :product_shares_tops,
                        :product_buy_clicks_tops
                       ]

  DATAS.keys.each do |key|
    case key
    when [:product_likes_tops, :reviews_plus_tops, :product_feelings_tops, :product_reviews_tops]
      field key, type: Hash
    else
      field key, type: String
    end
  end

  field :status, type: Symbol
  field :date_from, type: Date
  field :date_to, type: Date

  def self.generate_stats(date_from, date_to)
    @@date_from = date_from
    @@date_to = date_to
    stat = Stat.new
    stat.status = case date_to - date_from
                  when 0
                    :day
                  when 6
                    :week
                  else
                    :month
                  end
    stat.date_from = date_from
    stat.date_to = date_to
    DATAS.keys.each { |key| stat[key] = stat.send(key) if stat.respond_to?(key) }
    stat.save
  end

  def self.generate_day_stats(date = Date.yesterday)
    Stat.generate_stats(date, date)
  end

  def self.generate_week_stats(date = Date.yesterday)
    Stat.generate_stats(date.beginning_of_week, date.end_of_week)
  end

  def self.generate_month_stats(date = Date.yesterday)
    Stat.generate_stats(date.beginning_of_month, date.end_of_month)
  end

  def users_count
    User.where(:created_at.gte => @@date_from).where(:created_at.lte => @@date_to.next_day).size
  end

  def users_total_count
    User.where(:created_at.lte => @@date_to.next_day).size
  end

  def login_activities
    Activity.by_type(:login_user).from_date(@@date_from).to_date(@@date_to)
  end

  def login_users
    # login_activities.map(&:user).uniq!.size
  end

  def user_logins
    # login_activities.size
  end

  def activities_users
    Activity.from_date(@@date_from).to_date(@@date_to).distinct(:user_id).size
  end

  def ave_follows_count
    all_uniq_users = all_follows_activities.distinct(:user_id)
    all_follows_activities.size / all_uniq_users.size
  end

  def ave_followers_count
    all_uniq_users = all_follows_activities.distinct(:reference_union)
    all_follows_activities.size / all_uniq_users.size
  end

  def likes_count
    all_likes.size
  end

  def product_likes_tops
    all_likes_groups = all_likes.group_by(&:reference_union)
    result = {}
    all_likes_groups.sort_by { |k, v| v.count }.reverse.take(10).each do |thing|
      result[Thing.find(thing[0].split("_").last).title] = thing[1].size
    end
    result
  end

  def plus_one_count
    all_plus_one.size
  end

  def reviews_plus_tops
    reviews_plus = Activity.where(:type => :love_review).from_date(@@date_from).to_date(@@date_to)
    plus_ones = reviews_plus.map(&:reference)
    uniqs = plus_ones.uniq.compact
    result = Hash[uniqs.map { |v| [v.title, plus_ones.count(v)] }].sort_by { |_, value| value }.reverse.take(10)
    Hash[result.map { |item| [item[0], item[1]] }]
  end

  def feelings_count
    all_feelings.size
  end

  def product_feelings_tops
    product_something_tops(Feeling)
  end

  def reviews_count
    all_reviews.size
  end

  def product_reviews_tops
    product_something_tops(Review)
  end

  def new_products_count
    new_things.size
  end

  def products_count
    all_things.size
  end

  def has_link_products_count
    all_things.where(:shop.ne => "").size
  end

  def dsell_products_count
    all_things.where(:stage => :dsell).size
  end

  def has_reviews_products_count
    all_things.where(:reviews_count.gt => 0).size
  end

  def groundbreaking_reviews_products_count
    all_uniq_things = Thing.where(:id.in => all_reviews.map(&:thing_id))
    things_count = 0
    all_uniq_things.each do |t|
      if t.reviews.where(:created_at.gte => @@date_from).where(:created_at.lte => @@date_to.next_day).exists?
        things_count += 1
      end
    end
    things_count
  end

  def sale_sum
    all_orders.map(&:trade_price).select { |p| !p.nil? }.reduce(&:+)
  end

  def orders_count
    all_orders.size
  end

  def orders_users_count
    User.where(:id.in => Order.from_date(@@date_from).to_date(@@date_to).map(&:user_id)).size
  end

  def per_customer_sales
    sale_sum / orders_users_count
  end

  def all_order_items
    items = []
    all_orders.each { |o| items += o.order_items }
    items
  end

  def sorted_items
    uniq_things = all_order_items.map(&:thing_title).uniq
    thing_sale_times = {}
    uniq_things.each do |t|
      thing_sale_times[t] = all_order_items.select { |i| i.thing_title == t }.map(&:quantity).reduce(&:+)
    end
    thing_sale_times.sort_by { |_, times| times }
  end

  def most_sales_product
    sorted_items.reverse.take(1).flatten
  end

  def less_sales_product
    sorted_items.take(1).flatten
  end

  def has_purchased_users_count
    all_orders.map(&:user).uniq.size
  end

  private

  def all_likes
    @_all_likes ||= Activity.by_type(:fancy_thing).from_date(@@date_from).to_date(@@date_to)
  end

  def all_plus_one
    @_all_plus_one ||= Activity.where(:type.in => [:love_review, :love_feeling, :love_topic]).from_date(@@date_from).to_date(@@date_to)
  end

  def all_follows_activities
    @_all_follows_activities ||= Activity.by_type(:follow_user).from_date(@@date_from).to_date(@@date_to)
  end

  def all_orders
    @_all_orders ||= Order.where(:state.in => [:confirmed, :shipped]).from_date(@@date_from).to_date(@@date_to)
  end

  def all_feelings
    @_all_feelings ||= Activity.by_type(:new_feeling).from_date(@@date_from).to_date(@@date_to)
  end

  def all_reviews
    @_all_reviews ||= Review.where(:created_at.gte => @@date_from).where(:created_at.lte => @@date_to.next_day)
  end

  def new_things
    @_new_things ||= Thing.where(:created_at.gte => @@date_from).where(:created_at.lte => @@date_to.next_day)
  end

  def all_things
    @_all_things ||= Thing.where(:created_at.lte => @@date_to.next_day)
  end

  def product_something_tops(klass)
    result = {}
    klass.where(:created_at.gte => @@date_from).where(:created_at.lte => @@date_to.next_day)
      .group_by(&:thing_id).sort_by{ |k, v| v.count }.reverse.take(10).each do |thing|
      result[Thing.find(thing[0]).title] = thing[1].size
    end
    result
  end

end
