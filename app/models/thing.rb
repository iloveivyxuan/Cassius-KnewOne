# -*- coding: utf-8 -*-
class Thing < Post
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes

  include UserStatsable

  slug :title, history: true
  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :photo_ids, type: Array, default: []
  field :categories, type: Array, default: []
  after_save :update_categories

  field :related_thing_ids, type: Array, default: []

  field :shop, type: String, default: ""
  field :price, type: Float
  field :price_unit, type: String, default: "¥"
  field :shopping_desc, type: String, default: ""
  field :period, type: DateTime
  field :target, type: Float, default: 0
  CURRENCY_LIST = %w{¥ $ € £}

  field :priority, type: Integer, default: 0
  field :recommended, type: Boolean, default: false
  field :lock_priority, type: Boolean, default: false

  field :sharing_text, type: String

  field :stage, type: Symbol, default: :concept
  STAGES = {
      concept: "研发中",
      domestic: "国内导购",
      abroad: "国外海淘",
      invest: "众筹",
      dsell: "自销"
  }
  validates :stage, inclusion: {in: STAGES.keys}

  def safe_destroy?
    !Order.where('order_items.thing_id' => self.id).exists?
  end

  include Fancyable
  has_and_belongs_to_many :fanciers, class_name: "User", inverse_of: :fancies

  field :scores, type: Array, default: []

  # TODO: will remove in future
  has_many :reviews, dependent: :delete
  has_one :thing_group
  after_create do
    create_thing_group(name: self.title, founder: self.author) unless self.thing_group
  end

  has_and_belongs_to_many :owners, class_name: "User", inverse_of: :owns

  has_many :stories, dependent: :delete

  has_many :lotteries, dependent: :delete

  scope :published, -> { lt(created_at: Time.now) }
  scope :prior, -> { unscoped.published.gt(priority: 0).desc(:priority, :created_at) }
  scope :self_run, -> { unscoped.published.in(stage: [:dsell, :invest]).desc(:priority, :created_at) }
  default_scope -> { desc(:created_at) }

  STAGES.each do |k, v|
    scope k, -> { unscoped.published.where(stage: k) }
  end

  embeds_many :kinds
  accepts_nested_attributes_for :kinds, allow_destroy: true

  embeds_many :investors

  after_update :inc_karma

  def photos
    Photo.find_with_order photo_ids
  end

  def cover
    begin
      Photo.find photo_ids.first
    rescue Mongoid::Errors::DocumentNotFound
      Photo.new
    end
  end

  def categories_text
    (categories || []).join ','
  end

  def categories_text=(text)
    self.categories = text.split(',').map(&:strip).reject(&:blank?).uniq
  end

  def update_categories
    return unless categories_changed?
    old = categories_change.first || []
    new = categories_change.last || []
    (old - new).each { |c| Category.find_and_minus c }
    (new - old).each { |c| Category.find_and_plus c }
  end

  def top_review
    reviews.where(is_top: true).first
  end

  def own(user)
    return if owned?(user)
    owners << user
    user.inc karma: Settings.karma.own
  end

  def unown(user)
    return unless owned?(user)
    owners.delete user
    user.inc karma: -Settings.karma.own
  end

  def owned?(user)
    owners.include? user
  end

  def valid_kinds
    kinds.ne(stage: :hidden).sort_by { |k| k.photo_number }
  end

  def add_score(score)
    scores[score] ||= 0
    scores[score] += 1
    save
  end

  def del_score(score)
    return if score.nil? || scores[score].nil? || scores[score] <= 0
    scores[score] -= 1
    save
  end

  def inc_karma
    return unless priority_changed?
    old_priority = changed_attributes["priority"]
    old_priority ||= 0
    if old_priority <= 0 and priority > 0
      author.inc karma: Settings.karma.thing
    elsif old_priority > 0 and priority <= 0
      author.inc karma: -Settings.karma.thing
    end
  end

  def self_run?
    [:invest, :dsell].include? stage
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

  def related_things(lazy = Rails.env.development?)
    ids = lazy ? cal_related_thing_ids : (self.related_thing_ids || [])
    Thing.in(id: ids).sort_by {|t| ids.index(t.id.to_s)}
  end

  class << self
    def resort!
      ordered_things = []

      things = self.where(lock_priority: false).gt(priority: 0).to_a.shuffle

      self_run = things.select(&:self_run?).group_by(&:recommended?).values.reduce(&:+).reverse
      ugc = (things - self_run).group_by(&:recommended?).values.reduce &:+
      count = things.count

      self_run.each do |s|
        s.priority = count
        count -= 1
        ordered_things<< s

        (Random.new(SecureRandom.uuid.gsub(/[-a-z]/, '').to_i).rand(87) % 4).times do
          t = ugc.pop
          t.priority = count
          count -= 1
          ordered_things<< t
        end
      end

      ugc.each do |t|
        t.priority = count
        count -= 1
        ordered_things<< t
      end

      ordered_things.each { |t| t.save(validate: false) }
    end

    def rand_records(per = 1)
      (0...Thing.count).to_a.shuffle.slice(0, per).map { |i| Thing.skip(i).first }
    end

    def recal_all_related_things
      Thing.all.each {|t| t.update_related_thing_ids; t.save}
    end
  end
end
