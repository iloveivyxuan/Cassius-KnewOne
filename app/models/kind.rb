# -*- coding: utf-8 -*-
class Kind
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  embedded_in :thing

  field :stock, type: Integer, default: 0
  field :title, type: String, default: ''
  field :note, type: String, default: ''
  field :price, type: BigDecimal, default: 0.0

  field :selling, type: Boolean, default: false

  field :stage, type: Symbol, default: :stock
  field :estimates_at, type: DateTime

  STAGES = {
      stock: "现货",
      ship: "即将到货",
      exclusive: "限量",
      hidden: "下架"
  }
  validates :stage, inclusion: { in: STAGES.keys }

  scope :selling, -> { ne stage: :hidden }
  scope :has_stock, -> { gt stock: 0 }

  mount_uploader :photo, ImageUploader
end
