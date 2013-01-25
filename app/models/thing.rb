# -*- coding: utf-8 -*-
class Thing < Post
  field :shop, type: String, default: ""
  field :price, type: Float
  field :subtitle, type: String, default: ""
  field :official_site, type: String, default: ""
  field :description, type: String, default: ""
  field :stock, type: Integer
  field :recommend, type: Boolean, default: false
  field :top, type: Boolean, default: false
  field :photo_ids, type: Array, default: []
  field :scores, type: Array, default: []

  include Mongoid::Slug
  slug :title

  has_many :reviews

  validates :description, length: { maximum: 2048 }

  scope :recommended, where(recommend: true)
  scope :toped, where(top: true)

  def photos
    Photo.find_with_order photo_ids
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
