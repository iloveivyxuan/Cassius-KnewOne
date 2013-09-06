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

  before_validation do
    # simple_form BUG!!! datetime field can not mix up in nested form, Hack for now
    datetime = []
    (1..5).each do |i|
      datetime<< attributes.delete("estimates_at(#{i}i)").to_i
    end
    self.estimates_at = Time.new *datetime if datetime.reduce(&:+) != 0
  end

  STAGES = {
      stock: "现货",
      ship: "即将到货",
      exclusive: "限量"
  }
  validates :stage, inclusion: { in: STAGES.keys }

  scope :selling, -> { where :selling => true }
  scope :has_stock, -> { where :stock.gt => 0 }

  mount_uploader :photo, ImageUploader

  def self.find_kind_by_thing(thing_id, id)
    Thing.find(thing_id).find_kind(id)
  end
end
