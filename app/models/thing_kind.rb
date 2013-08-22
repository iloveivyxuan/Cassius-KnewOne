# -*- coding: utf-8 -*-
class ThingKind
  include Mongoid::Document

  belongs_to :thing

  field :stock, type: Integer, default: 0
  field :title, type: String, default: ''
  field :note, type: String, default: ''
  field :price, type: BigDecimal, default: 0.0

  field :selling, type: Boolean, default: false

  scope :selling, -> { where :selling => true }

  mount_uploader :photo, ImageUploader
end
