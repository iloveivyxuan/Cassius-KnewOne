# encoding: utf-8
class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  embedded_in :user

  field :quantity, type: Integer, :default => 1
  field :kind_id, type: String

  validates :quantity, :user, :thing, :kind_id, :presence => true
  validate do
    errors.add :quantity, "#{kind.title} 超过库存。" if kind.stock < self.quantity
  end
  validates :quantity, :numericality => {
      only_integer: true,
      greater_than: 0 }

  def price
    self.kind.price * self.quantity
  end

  def has_enough_stock?
    kind.stock >= self.quantity
  end

  def kind
    thing.find_kind self.kind_id
  end

  def quantity_increment(quantity)
    self.quantity += quantity
    self.quantity = kind.stock unless has_enough_stock?
  end

  def self.find_by_thing_and_kind(thing_id, kind_id)
    where(thing: thing_id, kind_id: kind_id).first
  end

  def self.find_by_kind(kind)
    where(thing: kind.thing.id, kind_id: kind.id).first
  end
end
