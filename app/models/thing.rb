class Thing < Post
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes
  include Aftermath

  slug :title, history: true
  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :photo_ids, type: Array, default: []
  field :categories, type: Array, default: []
  after_save :update_categories
  before_save :update_amazon_link

  belongs_to :maker, class_name: "User", inverse_of: nil

  field :related_thing_ids, type: Array, default: []

  field :shop, type: String, default: ""
  field :price, type: Float
  field :price_unit, type: String, default: "¥"
  field :shopping_desc, type: String, default: ""
  field :period, type: DateTime
  CURRENCY_LIST = %w{¥ $ € £}

  field :priority, type: Integer, default: 0
  field :recommended, type: Boolean, default: false

  field :sharing_text, type: String

  validates :title, presence: true
  validates :content, presence: true

  field :stage, type: Symbol, default: :concept
  STAGES = {
      concept: "研发中",
      kick: "众筹中",
      pre_order: "预售",
      domestic: "国内导购",
      abroad: "国外海淘",
      dsell: "自销"
  }
  validates :stage, inclusion: {in: STAGES.keys}

  def safe_destroy?
    !Order.where('order_items.thing_id' => self.id).exists?
  end

  include Fancyable
  has_and_belongs_to_many :fanciers, class_name: "User", inverse_of: :fancies

  has_and_belongs_to_many :fancy_groups, class_name: "Group", inverse_of: :fancies

  has_many :reviews, dependent: :destroy
  field :reviews_count, type: Integer, default: 0

  has_many :feelings, dependent: :destroy
  field :feelings_count, type: Integer, default: 0

  has_and_belongs_to_many :owners, class_name: "User", inverse_of: :owns

  has_many :stories, dependent: :destroy

  has_many :lotteries, dependent: :destroy

  scope :hot, -> { gt(fanciers_count: 30) }
  scope :published, -> { lt(created_at: Time.now) }
  scope :prior, -> { gt(priority: 0).desc(:priority, :created_at) }
  scope :self_run, -> { send :in, stage: [:dsell, :pre_order] }
  scope :price_between, ->(from, to) { where :price.gt => from, :price.lt => to }

  STAGES.each do |k, v|
    scope k, -> { where(stage: k) }
  end

  embeds_many :kinds
  accepts_nested_attributes_for :kinds, allow_destroy: true

  def photos
    Photo.find_with_order photo_ids
  end

  def cover
    begin
      Photo.find photo_ids.first
    rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
      Photo.new
    end
  end

  def categories_text
    (categories || []).join ','
  end

  def categories_text=(text)
    self.categories = text.split(',').map(&:strip).reject(&:blank?).uniq
  end

  def category_records
    Category.any_in(name: self.categories)
  end

  def update_categories
    return unless categories_changed?
    old = categories_change.first || []
    new = categories_change.last || []
    (old - new).each { |c| Category.find_and_minus c }
    (new - old).each { |c| Category.find_and_plus c }
  end

  def update_amazon_link
    if self.shop_changed? && self.shop.include?("amazon.cn") && !self.shop.include?("kne09-23")
      new_link = add_param(self.shop, "tag", "kne09-23")
      self.shop = new_link unless new_link.nil?
    end
  end

  # before: http://www.amazon.com/gp/product/B0052IGZFO
  # after:  http://www.amazon.com/gp/product/B0052IGZFO?foo=bar
  def add_param(url, param_name, param_value)
    begin
      uri = URI.parse(url)
    rescue
      uri = nil
    end

    unless uri.nil?
      uri.query = [uri.query, "#{param_name}=#{param_value}"].compact.join('&')
      uri.to_s
    end
  end

  def top_review
    reviews.where(is_top: true).first
  end

  def own(user)
    return if owned?(user)

    self.push(owner_ids: user.id)
    user.push(own_ids: self.id)

    reload
    user.reload

    user.inc karma: Settings.karma.own
  end

  def unown(user)
    return unless owned?(user)
    owners.delete user
    user.owns.delete self
    user.inc karma: -Settings.karma.own
  end

  def owned?(user)
    owner_ids.include? user.id
  end

  def valid_kinds
    kinds.ne(stage: :hidden).sort_by { |k| k.photo_number }
  end

  def self_run?
    [:dsell, :pre_order].include? stage
  end

  def cal_related_thing_ids(limit = 10, cate_power = 50, own_power = 2, fancy_power = 1)
    list = {}

    Thing.any_in(categories: self.categories).each do |thing|
      id = thing.id.to_s
      list[id] = 0
      self.categories.each do |c|
        list[id] += cate_power if thing.categories.include? c
      end
    end

    self.fanciers.map(&:fancy_ids).each do |thing_ids|
      thing_ids.each do |t|
        id = t.to_s
        if list[id]
          list[id] += fancy_power
        else
          list[id] = fancy_power
        end
      end
    end

    self.owners.map(&:own_ids).each do |thing_ids|
      thing_ids.each do |t|
        id = t.to_s
        if list[id]
          list[id] += own_power
        else
          list[id] = own_power
        end
      end
    end

    list.delete self.id.to_s

    powers = list.values
    powers.uniq! && powers.sort! && powers.reverse! # O(n log n)
    r = []
    powers.each do |power|
      r += list.select {|k, v| v == power}.keys # O(n)
      break if r.size >= limit
    end

    r[0..(limit-1)]
  end

  def update_related_thing_ids
    self.related_thing_ids = cal_related_thing_ids
  end

  def related_things(size = 10, lazy = Rails.env.development?)
    ids = lazy ? cal_related_thing_ids : (self.related_thing_ids || [])
    Thing.in(id: ids).limit(size).sort_by {|t| ids.index(t.id.to_s)}
  end

  def has_stock?
    return false unless self_run?
    kinds.map(&:has_stock?).reduce(&:|)
  end

  def notify_fanciers_stock(options = {})
    ThingNotificationWorker.perform_async(self.id.to_s, :fanciers, :stock, options)
  end

  need_aftermath :own, :unown, :fancy, :unfancy

  class << self
    def rand_records(per = 1)
      (0...Thing.published.count).to_a.shuffle.slice(0, per).map { |i| Thing.published.desc(:created_at).skip(i).first }
    end

    def rand_prior_records(per = 1)
      (0...Thing.published.prior.count).to_a.shuffle.slice(0, per).map { |i| Thing.published.desc(:created_at).prior.skip(i).first }
    end

    def recal_all_related_things
      Thing.all.each {|t| t.update_related_thing_ids; t.save}
    end
  end
end
