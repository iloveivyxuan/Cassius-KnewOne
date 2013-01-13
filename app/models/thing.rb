# -*- coding: utf-8 -*-
class Thing < Post
  field :description, type: String, default: ""

  has_many :photos, as: :photographic

  validates :description, length: { maximum: 2048 }
end
