# -*- coding: utf-8 -*-
class Kind
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  embedded_in :thing

  field :stock, type: Integer, default: 0
  field :title, type: String, default: ''
  field :note, type: String, default: ''
  field :photo_number, type: Integer, default: 0
  field :price, type: BigDecimal, default: 0.0

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
end
