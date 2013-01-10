# -*- coding: utf-8 -*-
class Thing < Post
  field :description, type: String, default: ""

  has_and_belongs_to_many :photos, inverse_of: nil

  validates :description, length: { maximum: 2048 }

  validate do |thing|
    errors.add(:photos, "请上传至少一张图片") if thing.photos.blank?
  end
end
