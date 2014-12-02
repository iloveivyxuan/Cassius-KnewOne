class Thing < Post
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes
  include Aftermath

  slug :title, history: true
  before_save :delete_illegal_chars

  index priority: 1

  field :approved_at, type: DateTime, default: nil
  before_save :update_approved_time

  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :photo_ids, type: Array, default: []
  field :categories, type: Array, default: []
  before_save :update_price
  before_save :update_amazon_link

  has_many :single_feelings, class_name: "Feeling", dependent: :destroy
  field :feelings_count, type: Integer, default: 0
  has_many :single_reviews, class_name: "Review", dependent: :destroy
  field :reviews_count, type: Integer, default: 0
  before_save :update_counts

  field :brand_name, type: String, default: ""
  field :brand_information, type: String, default: ""

  field :links, type: Array, default: []

  belongs_to :maker, class_name: "User", inverse_of: nil

  field :related_thing_ids, type: Array, default: []

  field :shop, type: String, default: ""
  field :price, type: Float
  PRICE_LIST = [1, 100, 200, 500, 1000, Float::INFINITY]
  field :price_unit, type: String, default: "¥"
  field :shopping_desc, type: String, default: ""
  field :period, type: DateTime
  CURRENCY_LIST = %w{¥ $ € £ JPY¥ ₩ NT$ C$ HK$}

  field :priority, type: Integer, default: 0

  before_create :update_priority

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
    adoption: "领养",
    dsell: "自销"
  }
  validates :stage, inclusion: {in: STAGES.keys}
  before_save :update_stage

  def safe_destroy?
    !Order.where('order_items.thing_id' => self.id).exists?
  end

  include Fanciable
  fancied_as :fancies

  has_and_belongs_to_many :owners, class_name: "User", inverse_of: :owns

  has_many :stories, dependent: :destroy

  has_many :lotteries, dependent: :destroy

  has_many :adoptions, dependent: :destroy

  has_and_belongs_to_many :tags, counter_cache: true

  belongs_to :resource

  scope :recent, -> { gt(created_at: 1.month.ago) }
  scope :published, -> { lt(created_at: Time.now) }
  scope :reviewed, -> { gt(reviews_count: 0).desc(:priority, :created_at) }
  scope :prior, -> { gt(priority: 0).desc(:priority, :created_at) }
  scope :self_run, -> { send :in, stage: [:dsell, :pre_order] }
  scope :price_between, ->(from, to) { where :price.gt => from, :price.lt => to }
  scope :linked, -> { nin(links: [nil, []]) }
  scope :approved, -> { gt(priority: 0) }
  scope :by_tag, -> (tag) { any_in('tag_ids' => tag.id) }
  scope :by_brand, -> (brand) { where('brand_id' => brand.id) }
  scope :no_brand, -> { where('brand_id' => nil) }

  STAGES.each do |k, v|
    scope k, -> { where(stage: k) }
  end

  embeds_many :kinds
  accepts_nested_attributes_for :kinds, allow_destroy: true
  belongs_to :brand

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

  def lists
    ThingList.where('thing_list_items.thing_id' => id)
  end

  after_destroy do
    lists.each do |list|
      list.items.where(thing_id: id).destroy
    end
  end

  def resource_text=(text)
    @resource = Resource.where(name: text).first
    self.resource = @resource if @resource
  end

  def resource_text
    self.resource.try(:name)
  end

  def categories_text
    (categories || []).join ','
  end

  def categories_text=(text)
    self.categories = text.split(',').map(&:strip).reject(&:blank?).uniq
  end

  def tags_text
    (tags.map(&:name) || []).join ','
  end

  def tags_text=(text)
    self.tags = text.split(/[，,]/).map do |tag_name|
      Tag.find_by(name: tag_name.strip)
    end
    categories = self.tags.map(&:categories).flatten
    categories += categories.map(&:category)
    self.categories = categories.compact.uniq.map(&:name)
  end

  def brand_text=(text)
    if text.empty?
      self.brand = nil
    else
      text.strip!
      if /[a-zA-Z0-9]/ =~ text
        q = Regexp.escape(text)
        brand = Brand.where(en_name: /^#{q}$/i).first
        brand ||= Brand.create(en_name: text)
        self.brand = brand
      else
        brand = Brand.where(zh_name: /#{text}/i).first
        brand ||= Brand.create(zh_name: text)
        self.brand = brand
      end
    end
  end

  def category_records
    Category.any_in(name: self.categories)
  end

  def primary_categories
    category_records.primary.pluck(:name)
  end

  def update_price
    kinds_price = valid_kinds.map(&:price).uniq
    self.price = kinds_price.min if kinds_price.present?
  end

  def update_amazon_link
    if self.shop_changed? && self.shop && self.shop.include?("amazon.cn") && !self.shop.include?("kne09-23")
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

  def cal_related_thing_ids(limit = 10, cate_power = 50, own_power = 2, fancy_power = 1, brand_power = 100)
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

    Thing.where(brand_id: self.brand_id).pluck(:id).map(&:to_s).each do |id|
      if list[id]
        list[id] += brand_power
      else
        list[id] = brand_power
      end
    end if self.has_brand?

    list.delete self.id.to_s
    list.except!(*self.links.map(&:to_s))

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
    set(related_thing_ids: cal_related_thing_ids)
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

  include Rankable

  def birth_time
    approved_at || Time.at(0)
  end

  def calculate_heat
    self.priority ||= 0

    (1 +
     priority +
     25 * reviews_count +
     5 * feelings_count +
     lists.count +
     fancier_ids.count +
     owner_ids.count) *
    freezing_coefficient
  end

  def feelings
    if links.blank?
      single_feelings
    else
      Feeling.in(thing_id: links)
    end
  end

  def has_feelings?
    feelings.count > 0
  end

  def fanciers_count
    if links.blank?
      fanciers.count
    else
      links.map { |l| Thing.find(l).fanciers.count }.reduce(&:+)
    end
  end

  def owners_count
    if links.blank?
      owners.count
    else
      links.map { |l| Thing.find(l).owners.count }.reduce(&:+)
    end
  end

  def reviews
    if links.blank?
      single_reviews
    else
      Review.in(thing_id: links)
    end
  end

  def has_reviews?
    reviews.count > 0
  end

  # get all linked things of a specific thing.
  # return Array or empty Array.
  def all_links
    if self.links.blank?
      return []
    else
      self.links.map { |l| Thing.find(l) }
    end
  end

  # delete all linked things of a specific thing.
  def delete_links
    self.all_links.each { |t| t.update_attributes(links: []) }
  end

  def adopted_by? user
    adoptions.where(user: user).exists?
  end

  class << self
    def rand_records(per = 1)
      (0...Thing.published.count).to_a.shuffle.slice(0, per).map { |i| Thing.published.desc(:created_at).skip(i).first }
    end

    def rand_prior_records(per = 1)
      (0...Thing.published.prior.count).to_a.shuffle.slice(0, per).map { |i| Thing.published.desc(:created_at).prior.skip(i).first }
    end

    def recal_all_related_things
      Thing.desc(:created_at).no_timeout.each(&:update_related_thing_ids)
    end
  end

  include Searchable

  searchable_fields [:title, :_slugs, :subtitle, :brand_name, :content]

  def as_indexed_json(options={})
    {
      title: self.title,
      slugs: self.slugs,
      subtitle: self.subtitle,
      brand: self.brand_name,
      content: ActionController::Base.helpers.strip_tags(self.content)
    }
  end

  def self.search(query)
    options = {
      multi_match: {
        query: query,
        fields: ['title^10', 'slugs^5', 'subtitle^3', 'brand^3', 'content']
      }
    }

    __elasticsearch__.search(query: options, min_score: 2)
  end

  private

  def update_counts
    self.feelings_count = feelings.size
    self.reviews_count = reviews.size
  end

  # delete ~, which may cause slug to be 'foo-bar-~', which cannot be found.
  def delete_illegal_chars
    self.title.delete!("~")
  end

  def update_approved_time
    self.priority = 0 unless self.priority.is_a?(Integer)
    if self.approved_at.nil? && self.priority > 0
      self.approved_at = Time.now
    end
  end

  def update_priority
    if self.author.role?(:editor)
      self.priority = 1
    end
  end

  def update_stage
    if self.shop_changed? && self.shop_was.blank? && !self.shop.blank?
      if %w(kickstarter indiegogo pozible demohour z.jd zhongchou hi.taobao.com).map { |rule| shop.include?(rule) }.include?(true)
          self.stage = :kick
      elsif ['¥', 'NT$', 'HK$'].include?(self.price_unit)
        self.stage = :domestic
      else
        self.stage = :abroad
      end
    end
  end

end
