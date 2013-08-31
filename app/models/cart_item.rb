# encoding: utf-8
class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  belongs_to :user
  belongs_to :kind, class_name: 'ThingKind'

  field :quantity, type: Integer, :default => 1

  validates :quantity, :user, :thing, :kind, :presence => true
  validate do
    errors.add :quantity, "#{kind.title} 超过库存。" if kind.stock < self.quantity
  end
  validates :quantity, :numericality => {
      only_integer: true,
      greater_than: 0 }

  def price
    self.kind.price * self.quantity
  end

  def has_stock?
    kind.stock >= self.quantity
  end
end
