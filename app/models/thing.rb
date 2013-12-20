# -*- coding: utf-8 -*-
class Thing < Post
  include Mongoid::Slug
  include Mongoid::MultiParameterAttributes

  has_and_belongs_to_many :local_tyrants, class_name: 'User'

  slug :title, history: true
  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :photo_ids, type: Array, default: []

  field :shop, type: String, default: ""
  field :price, type: Float
  field :price_unit, type: String, default: "¥"
  field :shopping_desc, type: String, default: ""
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
    dsell: "自销",
  }
  validates :stage, inclusion: { in: STAGES.keys }

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
  scope :self_run, -> { unscoped.where(stage: :dsell).desc(:priority, :created_at) }
  default_scope desc(:created_at)

  embeds_many :kinds
  accepts_nested_attributes_for :kinds, allow_destroy: true

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
    kinds.ne(stage: :hidden).sort_by {|k| k.photo_number}
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
    (STAGES.keys.index(stage) || 0) > 2
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

      ordered_things.each {|t| t.save(validate: false)}
    end

    def rand_records(per = 1)
      (0...Thing.count).to_a.shuffle.slice(0, per).map { |i| Thing.skip(i).first }
    end
  end
end
