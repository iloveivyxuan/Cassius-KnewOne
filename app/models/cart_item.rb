class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  embedded_in :user

  field :quantity, type: Integer, default: 1
  field :kind_id, type: String

  validates :quantity, :user, :thing, :kind_id, presence: true
  validates :quantity, numericality: {
      only_integer: true,
      greater_than: 0,
      less_than: 999
  }

  def price
    kind.price * quantity
  end

  def legal?
    thing && thing.kinds.where(_id: self.kind_id).exists?
  end

  def has_enough_stock?
    kind.stock >= quantity && kind.stage != :hidden
  end

  def buyable?
    legal? && has_enough_stock?
  end

  def kind
    @kind ||= thing.kinds.find kind_id
  end

  def quantity_increment(quantity)
    q = self.quantity + quantity
    if q <= kind.max_buyable && q > 0
      self.quantity = q
    end
    self.quantity
  end

  def self.total_price(cart_items)
    cart_items.select(&:has_enough_stock?).map(&:price).reduce(&:+) || 0
  end
end
