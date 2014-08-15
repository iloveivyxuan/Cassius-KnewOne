class Stat
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :feelings, dependent: :destroy

  DATAS = {
    # 用户相关
    :users_count => '总用户数',
    :login_users => '登录用户数量',
    :user_logins => '用户登录次数',
    :activities_users => '有交互用户数',
    :ave_follows_count => '用户平均关注数量',
    :ave_followers_count => '用户平均被关注数量',
    :one_page_users_count => '只看一个页面的用户数量',
    :most_bounce_pages => '跳出率最高的页面',
    :less_bounce_pages => '跳出率最少的页面',
    :top_10_sources => '用户来源前 10',
    # 交互数据
    :likes_count => '总 like 数',
    :product_likes_tops => '分产品 like 数前 10',
    :plus_one_count => '总赞数',
    :plus_one_tops => '分产品赞数前 10',
    :feelings_count => '短评数',
    :product_feelings_tops => '分产品短评数前 10',
    :reviews_count => '评测数',
    :product_reviews_tops => '分产品评测数前 10',
    :shares_count => '分享数',
    :product_shares_tops => '分产品分享数前 10',
    :buy_clicks => '购买按钮点击数量',
    :product_buy_clicks_tops => '分产品购买按钮点击数前 10',
    # 产品相关
    :products_count => '总产品数',
    :has_link_products_count => '有购买链接产品数',
    :dsell_products_count => '自营产品数',
    :has_reviews_products_count => '有评测的产品数',
    # 销售
    :sale_sum => '销售额',
    :orders_count => '订单数',
    :orders_users_count => '下单的用户数',
    :per_customer_sales => '客单价',
    :most_sales_product => '销售最多的产品',
    :less_sales_product => '销售最少的产品',
    :has_purchased_users_count => '消费过的用户数',
    :ave_purchased_price => '平均消费金额'
  }

  # datas with text_area
  BUNCH_DATAS = [
                 :product_likes_tops,
                 :plus_one_tops,
                 :product_feelings_tops,
                 :product_reviews_tops
                ]

  # datas which need manual input
  MANUAL_INPUT_DATAS = [
                        :most_bounce_pages,
                        :less_bounce_pages,
                        :top_10_sources,
                        :product_shares_tops,
                        :product_buy_clicks_tops
                       ]

  DATAS.keys.each { |key| field key, type: String }

  field :date_from, type: Date
  field :date_to, type: Date

  field :note, type: String

  def self.generate_stats(stat, date_from, date_to)
    @@date_from = date_from
    @@date_to = date_to
    DATAS.keys.each { |key| stat[key] = stat.send(key) if stat.respond_to? key }
    stat
  end

  def to_topic(user, group)
    content = ""
    DATAS.keys.each do |key|
      content += "<b>#{DATAS[key]}</b>"
      if BUNCH_DATAS.include? key
        JSON.parse(self[key]).each do |s|
          content += "<div>#{s.first} | #{s.last} </div>"
        end
      else
        content += "<div>#{self[key]}</div>"
      end
    end
    if self.date_from == self.date_to
      title = "#{self.date_to} 数据"
    else
      title = "#{self.date_from} - #{self.date_to} 数据"
    end
    topic = Topic.create(
                         title: title,
                         content: content,
                         author: user,
                         group: group,
                         visible: false)
    topic
  end

  def users_count
    User.all.size
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
    Activity.from_date(@@date_from).to_date(@@date_to).all.map(&:user).uniq!.size
  end

  def all_follows
    Activity.by_type(:follow_user).from_date(@@date_from).to_date(@@date_to)
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
    Activity.by_type(:fancy_thing).from_date(@@date_from).to_date(@@date_to)
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
    Activity.where(:type.in => [:love_review, :love_feeling, :love_topic]).from_date(@@date_from).to_date(@@date_to)
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
    Activity.by_type(:new_feeling).from_date(@@date_from).to_date(@@date_to)
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
    Activity.by_type(:new_review).from_date(@@date_from).to_date(@@date_to)
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
    Activity.by_type(:new_thing).from_date(@@date_from).to_date(@@date_to).map(&:reference)
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
    Order.where(:state.in => [:confirmed, :shipped]).from_date(@@date_from).to_date(@@date_to)
  end

  def sale_sum
    all_orders.map(&:trade_price).select { |p| !p.nil? }.reduce(&:+)
  end

  def orders_count
    all_orders.size
  end

  def orders_users_count
    Order.from_date(@@date_from).to_date(@@date_to).map(&:user).uniq.size
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

  def ave_purchased_price
    # todo
  end

end
