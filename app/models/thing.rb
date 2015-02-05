class Thing < Post
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes
  include Aftermath

  include Adoptable

  slug :title, history: true
  before_save :delete_illegal_chars

  field :approved_at, type: DateTime, default: nil
  index approved_at: -1
  before_save :update_approved_time

  field :subtitle, type: String, default: ""
  field :nickname, type: String
  field :official_site, type: String, default: ""
  field :photo_ids, type: Array, default: []

  has_and_belongs_to_many :categories, inverse_of: nil,
                          after_add: :after_add_category,
                          after_remove: :after_remove_category

  before_save :update_price
  before_save :update_amazon_link

  has_many :feelings, dependent: :destroy
  field :feelings_count, type: Integer, default: 0
  accepts_nested_attributes_for :feelings, auto_save: true

  has_many :reviews, dependent: :destroy
  field :reviews_count, type: Integer, default: 0

  field :brand_name, type: String, default: ""
  field :brand_information, type: String, default: ""

  field :links, type: Array

  belongs_to :maker, class_name: "User", inverse_of: nil

  field :related_thing_ids, type: Array, default: []

  field :shop, type: String, default: ""
  field :price, type: Float
  PRICE_LIST = [1, 100, 200, 500, 1000, Float::INFINITY]
  field :price_unit, type: String, default: "¥"
  field :shopping_desc, type: String, default: ""
  field :period, type: DateTime
  CURRENCY_LIST = %w{¥ $ € £ JPY¥ ₩ NT$ C$ HK$}

  field :priority, type: Integer, default: -1
  index({priority: -1, created_at: -1})

  before_create :update_priority

  field :sharing_text, type: String

  validates :title, presence: true
  validates :photo_ids, presence: true

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
  before_save :update_stage

  field :adoption, type: Boolean, default: false

  def safe_destroy?
    !Order.where('order_items.thing_id' => self.id).exists?
  end

  has_many :impressions
  field :fanciers_count, type: Integer, default: 0
  field :desirers_count, type: Integer, default: 0
  field :owners_count, type: Integer, default: 0
  index fanciers_count: -1

  def impression_by(user)
    impressions.by_user(user).first
  end

  def fancier_ids
    @_fancier_ids ||= impressions.fancied.pluck(:author_id)
  end

  def desirer_ids
    @_desirer_ids ||= impressions.desired.pluck(:author_id)
  end

  def owner_ids
    @_owner_ids ||= impressions.owned.pluck(:author_id)
  end

  def fanciers
    @_fanciers ||= User.in(id: fancier_ids)
  end

  def desirers
    @_desirers ||= User.in(id: desirer_ids)
  end

  def owners
    @_owners ||= User.in(id: owner_ids)
  end

  def fancy(user)
    impression = impressions.find_or_initialize_by(author: user)
    impression.update(fancied: true) unless impression.fancied
  end

  def desire(user)
    impression = impressions.find_or_initialize_by(author: user)
    impression.update(state: :desired) if impression.state != :desired
  end

  def own(user)
    impression = impressions.find_or_initialize_by(author: user)
    impression.update(state: :owned) if impression.state != :owned
  end

  def unfancy(user)
    impression = impressions.fancied.by_user(user).first
    impression.update(fancied: false) if impression
  end

  def undesire(user)
    impression = impressions.desired.by_user(user).first
    impression.update(state: :none) if impression
  end

  def unown(user)
    impression = impressions.owned.by_user(user).first
    impression.update(state: :none) if impression
  end

  def fancied?(user)
    impressions.fancied.by_user(user).exists?
  end

  def desired?(user)
    impressions.desired.by_user(user).exists?
  end

  def owned?(user)
    impressions.owned.by_user(user).exists?
  end

  field :tag_counts, type: Array, default: []

  def add_tag(tag)
    found = tag_counts.assoc(tag.id)
    if found
      found[1] += 1
    else
      tag_counts << [tag.id, 1]
    end
  end

  def remove_tag(tag)
    found = tag_counts.assoc(tag.id)
    found[1] -= 1 if found
  end

  def fix_tag_counts
    tag_counts = self.tag_counts.select { |a| a[1] > 0 }.sort_by(&:last).reverse
    set(tag_counts: tag_counts)
  end

  def popular_tags(limit)
    tag_ids = self.tag_counts.take(limit).map(&:first)
    Tag.only(:id, :name).in(id: tag_ids).sort_by { |tag| tag_ids.index(tag.id) }
  end

  has_many :stories, dependent: :destroy

  has_many :adoptions, dependent: :destroy

  belongs_to :resource

  scope :published, -> { lt(created_at: Time.now) }
  scope :reviewed, -> { gt(reviews_count: 0).desc(:priority, :created_at) }
  scope :prior, -> { gt(priority: 0).desc(:priority, :created_at) }
  scope :self_run, -> { send :in, stage: [:dsell, :pre_order] }
  scope :price_between, ->(from, to) { where :price.gt => from, :price.lt => to }
  scope :approved, -> { gte(priority: 0) }
  scope :recommended, -> { gt(priority: 0) }
  scope :by_brand, -> (brand) { where('brand_id' => brand.id) }
  scope :no_brand, -> { where('brand_id' => nil) }

  STAGES.each do |k, v|
    scope k, -> { where(stage: k) }
  end

  embeds_many :kinds
  accepts_nested_attributes_for :kinds, allow_destroy: true
  belongs_to :brand

  belongs_to :merchant, counter_cache: true

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
    categories.third_level.map(&:name).join(', ')
  end

  def categories_text=(text)
    self.categories = text.split(/[，,]/).map(&:strip).map { |name| Category.where(name: name).first }.compact
  end

  def brand_text=(text)
    text.strip!
    self.brand = if text.blank?
                   nil
                 elsif /[a-zA-Z0-9]/ =~ text
                   q = Regexp.escape(text)
                   brand = Brand.where(en_name: q).first
                   brand ||= Brand.where(en_name: /^#{q}$/i).first
                   brand ||= Brand.create(en_name: text)
                   brand
                 else
                   brand = Brand.where(zh_name: text).first
                   brand ||= Brand.where(zh_name: /#{text}/i).first
                   brand ||= Brand.create(zh_name: text)
                   brand
                 end
    brand_was = Brand.where(id: self.brand_id_was).first
    brand_is = Brand.where(id: self.brand_id).first
    brand_was.save if brand_was
    brand_is.save if brand_is
  end

  def merchant_name
    return "" unless self.merchant?
    self.merchant.name
  end

  def merchant_name=(name)
    if name.blank?
      self.merchant = nil
    else
      merchant = Merchant.find_by(name: name)
      self.merchant = merchant
      merchant.set(things_count: merchant.things.size)
    end
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

  def valid_kinds
    kinds.ne(stage: :hidden).sort_by { |k| k.photo_number || 0 }
  end

  def self_run?
    [:dsell, :pre_order].include? stage
  end

  def cal_related_thing_ids(limit = 10, cate_power = 50, desire_power = 1, own_power = 2, brand_power = 100)
    list = {}

    Thing.any_in(categories: self.categories).each do |thing|
      id = thing.id.to_s
      list[id] = 0
      self.categories.each do |c|
        list[id] += cate_power if thing.categories.include? c
      end
    end

    Impression.in(author_id: self.desirers.pluck(:id)).pluck(:thing_id).map(&:to_s).each do |id|
      if list[id]
        list[id] += desire_power
      else
        list[id] = desire_power
      end
    end

    Impression.in(author_id: self.owners.pluck(:id)).pluck(:thing_id).map(&:to_s).each do |id|
      if list[id]
        list[id] += own_power
      else
        list[id] = own_power
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
    list.except!(*self.links.map(&:to_s)) if self.links.present?

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

  def related_things(size = 10)
    ids = (self.related_thing_ids || []).take(size)
    Thing.in(id: ids).sort_by {|t| ids.index(t.id.to_s)}
  end

  def has_stock?
    return false unless self_run?
    kinds.map(&:has_stock?).reduce(&:|)
  end

  def notify_fanciers_stock(options = {})
    ThingNotificationWorker.perform_async(self.id.to_s, :fanciers, :stock, options)
  end

  include Rankable

  def birth_time
    approved_at || Time.at(0)
  end

  def calculate_heat
    self.priority ||= 0

    (1 +
     5 * priority +
     25 * reviews_count +
     5 * feelings_count +
     lists.count +
     fanciers_count +
     owners_count) *
    freezing_coefficient
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

  searchable_fields [:title, :_slugs, :subtitle, :nickname, :priority]

  mappings do
    indexes :title, copy_to: :ngram
    indexes :nickname, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
    indexes :suggest, type: 'completion'
  end

  alias_method :_as_indexed_json, :as_indexed_json
  def as_indexed_json(options={})
    suggest = priority < 0 ? {} : {
      input: ([title, slug.gsub('-', '')] + title.split(' ')).uniq,
      output: title,
      weight: fanciers_count
    }

    _as_indexed_json(options).merge(
      cover_id: photo_ids.first.to_s,
      brand_name: brand.try(:full_name),
      fanciers_count: fanciers_count,
      owners_count: owners_count,
      reviews_count: reviews_count,
      updated_at: updated_at,
      suggest: suggest
    )
  end

  def self.search(query)
    return __elasticsearch__.search('') if query.blank?

    query_options = {
      function_score: {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'subtitle^3', 'nickname^5', 'brand_name^7', 'ngram^5'],
            tie_breaker: 0.1,
            minimum_should_match: '2<75%'
          }
        },
        field_value_factor: {
          field: 'fanciers_count',
          factor: 0.1,
          modifier: 'log1p'
        },
        max_boost: 1.4,
        boost_mode: 'sum'
      }
    }

    filter_options = {
      range: {
        priority: {gte: 0}
      }
    }

    options = {
      query: query_options,
      filter: filter_options,
      min_score: 0.1
    }

    result = __elasticsearch__.search(options)
    return result if result.present?

    self.search(suggest(query).first)
  end

  def __elasticsearch__.__find_in_batches(options={}, &block)
    batch_size = options[:batch_size] || 1000
    Thing.includes(:brand).desc(:id).no_timeout
      .only(:id, :slugs, :brand_id, :photo_ids, :updated_at,
            :title, :subtitle, :nickname, :priority,
            :fanciers_count, :owners_count, :reviews_count,
           ).each_slice(batch_size, &block)
  end

  def self.suggest(prefix, limit = 10)
    body = {
      titles: {
        text: prefix,
        completion: {
          field: :suggest,
          size: limit
        }
      }
    }

    response = __elasticsearch__.client.suggest(index: index_name, body: body)
    response['titles'].first['options'].map { |h| h['text'].strip } rescue []
  end

  def fix_categories
    third_level_categories = self.categories.third_level
    second_level_categories = third_level_categories.map(&:parent).uniq
    top_level_categories = second_level_categories.map(&:parent).uniq

    self.set(categories: top_level_categories + second_level_categories + third_level_categories)
  end

  private

  # delete ~, which may cause slug to be 'foo-bar-~', which cannot be found.
  def delete_illegal_chars
    self.title.delete!("~")
  end

  def update_approved_time
    self.priority ||= -1
    if ((priority_was.nil? || priority_was < 0) && priority >= 0) || (priority_was == 0 && priority > 0)
      self.approved_at = Time.now
      self.author.inc karma: Settings.karma.publish.thing if approved_at_was.nil?
    end
  end

  def update_priority
    self.priority = 0 if self.author.role?(:volunteer)
    self.priority = 1 if self.author.role?(:editor)
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

  def after_add_category(category)
    category.ancestors.each do |c|
      self.add_to_set(category_ids: c.id)
    end
  end

  def after_remove_category(category)
    fix_categories
  end
end
