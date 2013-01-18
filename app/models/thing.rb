# -*- coding: utf-8 -*-
class Thing < Post
  field :shop, type: String, default: ""
  field :price, type: Float
  field :description, type: String, default: ""
  field :photo_ids, type: Array, default: []

  validates :description, length: { maximum: 2048 }

  def photos
    Photo.find_with_order photo_ids
  end
end
