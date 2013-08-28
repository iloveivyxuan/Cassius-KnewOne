class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :single_price, type: BigDecimal

  belongs_to :thing_kind

  embedded_in :order

  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  def claim_stock!
    puts thing_kind.stock
    thing_kind.inc :stock, -self.quantity # always positive
    puts thing_kind.stock
  end

  def revert_stock!
    thing_kind.inc :stock, self.quantity
  end

  def price
    self.single_price * self.quantity
  end

  class<< self
    def build_by_cart_item(order, item)
      order.order_items.build({
        quantity: item.quantity,
        thing_kind: item.kind,
        single_price: item.kind.price
      })
    end
  end
end
