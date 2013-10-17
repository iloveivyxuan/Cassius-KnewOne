# encoding: utf-8
class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  embedded_in :user

  field :quantity, type: Integer, default: 1
  field :kind_id, type: String

  validates :quantity, :user, :thing, :kind_id, presence: true
  validate do
    errors.add :quantity, "#{kind.title} 超过库存。" if kind.stock < self.quantity
  end
  validates :quantity, numericality: {
      only_integer: true,
      greater_than: 0
  }

  def price
    kind.price * quantity
  end

  def legal?
    thing.kinds.where(_id: self.kind_id).exists?
  end

  def has_enough_stock?
    kind.stock >= quantity
  end

  def kind
    thing.kinds.find kind_id
  end

  def valid_kinds
    thing.kinds.ne(stage: :hidden)
  end

  def quantity_increment(quantity)
    self.quantity += quantity
  end

  def self.total_price(cart_items)
    cart_items.select(&:has_enough_stock?).map(&:price).reduce(&:+) || 0
  end
end
