# -*- coding: utf-8 -*-
class Thing < Post
  include Mongoid::Slug
  slug :title

  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :description, type: String, default: ""
  field :photo_ids, type: Array, default: []

  validates :description, length: { maximum: 2048 }

  field :shop, type: String, default: ""
  field :oversea_shop, type: String, default: ""
  field :price, type: Float
  field :price_unit, type: String, default: "¥"
  field :stock, type: Integer
  field :is_limit, type: Boolean, default: false
  field :is_self_run, type: Boolean, default: false

  field :priority, type: Integer, default: 0
  field :is_pre, type: Boolean, default: false
  field :pre_link, type: String, default: ""

  field :scores, type: Array, default: []
  field :fanciers_count, type: Integer, default: 0

  # https://github.com/jnicklas/carrierwave/issues/81
  embeds_many :packages, cascade_callbacks: true
  accepts_nested_attributes_for :packages, allow_destroy: true

  include Mongoid::MultiParameterAttributes

  has_many :reviews, dependent: :delete
  has_many :links, dependent: :delete
  has_and_belongs_to_many :fanciers, class_name: "User", inverse_of: :fancies
  has_and_belongs_to_many :owners, class_name: "User", inverse_of: :owns

  has_many :lotteries, dependent: :delete
  has_many :related_lotteries, class_name: "Lottery",
  inverse_of: :contributions, dependent: :delete

  validates :description, length: { maximum: 2048 }

  scope :published, -> { lt(created_at: Time.now) }

  scope :prior, -> { unscoped.published.gt(priority: 0).desc(:priority, :created_at) }

  default_scope desc(:created_at)

  after_update :inc_karma

  def photos
    Photo.find_with_order photo_ids
  end

  def top_review
    reviews.where(is_top: true).first
  end

  def fancy(user)
    return if fancied?(user)
    fanciers << user
    update_attribute :fanciers_count, fanciers.count
    user.inc :karma, Settings.karma.fancy
  end

  def unfancy(user)
    return unless fancied?(user)
    fanciers.delete user
    update_attribute :fanciers_count, fanciers.count
    user.inc :karma, -Settings.karma.fancy
  end

  def fancied?(user)
    fanciers.include? user
  end

  def own(user)
    return if owned?(user)
    owners << user
    user.inc :karma, Settings.karma.own
  end

  def unown(user)
    return unless owned?(user)
    owners.delete user
    user.inc :karma, -Settings.karma.own
  end

  def owned?(user)
    owners.include? user
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
      author.inc :karma, Settings.karma.thing
    elsif old_priority > 0 and priority <= 0
      author.inc :karma, -Settings.karma.thing
    end
  end

end
