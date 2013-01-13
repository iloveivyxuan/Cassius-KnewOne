# -*- coding: utf-8 -*-
class Thing < Post
  field :description, type: String, default: ""

  has_many :photos, as: :photographic

  validates :description, length: { maximum: 2048 }

  accepts_nested_attributes_for :photos

  validate do |thing|
    errors.add(:photos, "请上传至少一张图片") if thing.photos.blank?
  end
end
