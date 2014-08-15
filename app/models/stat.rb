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

end
