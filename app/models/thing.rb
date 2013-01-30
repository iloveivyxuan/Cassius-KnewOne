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

  def photos
    Photo.find_with_order photo_ids
  end

  def fancy(user)
    fanciers << user unless fancied?(user)
  end

  def unfancy(user)
    fanciers.delete user if fancied?(user)
  end

  def fancied?(user)
    fanciers.include? user
  end

  def own(user)
    owners << user unless owned?(user)
  end

  def unown(user)
    owners.delete user if owned?(user)
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
end
