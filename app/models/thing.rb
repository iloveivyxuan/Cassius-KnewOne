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

  has_many :reviews

  validates :description, length: { maximum: 2048 }

  scope :recommended, where(recommend: true)
  scope :toped, where(top: true)

  def photos
    Photo.find_with_order photo_ids
  end
end
