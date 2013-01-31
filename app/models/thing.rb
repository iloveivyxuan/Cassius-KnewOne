# -*- coding: utf-8 -*-
class Thing < Post
  field :shop, type: String, default: ""
  field :price, type: Float
  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :description, type: String, default: ""
  field :stock, type: Integer
  field :batch, type: Integer
  field :photo_ids, type: Array, default: []
  field :scores, type: Array, default: []
  field :is_shop, type: Boolean, default: false
  field :priority, type: Integer, default: 0

  include Mongoid::Slug
  slug :title

  has_many :reviews, dependent: :delete
  has_and_belongs_to_many :fanciers, class_name: "User", inverse_of: :fancies
  has_and_belongs_to_many :owners, class_name: "User", inverse_of: :owns

  validates :description, length: { maximum: 2048 }

  default_scope desc(:priority, :created_at)

  after_update :inc_karma

  def photos
    Photo.find_with_order photo_ids
  end

  def fancy(user)
    return if fancied?(user)
    fanciers << user
    user.inc :karma, Settings.karma.fancy
  end

  def unfancy(user)
    return unless fancied?(user)
    fanciers.delete user
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
    if old_priority <= 0 and priority > 0
      author.inc :karma, Settings.karma.thing
    elsif old_priority > 0 and priority <= 0
      author.inc :karma, -Settings.karma.thing
    end
  end

end
