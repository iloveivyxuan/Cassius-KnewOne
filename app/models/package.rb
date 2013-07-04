# -*- coding: utf-8 -*-
class Package
  include Mongoid::Document

  field :title, type: String, default: ""
  field :shop,  type: String, default: ""
  field :price, type: Float,  default: 0
  field :stock, type: Integer, default: 0
  mount_uploader :photo, ImageUploader
  embedded_in :thing

  attr_accessible :title, :shop, :price, :photo, :photo_cache
end
