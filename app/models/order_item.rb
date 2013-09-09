class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :single_price, type: BigDecimal

  belongs_to :thing
  field :kind_id, type: String
  validates :kind_id, :presence => true

  embedded_in :order

  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  def claim_stock!
    # protect race condition, over selling should throw nil error
    thing.kinds.where(:id => self.kind_id, :stock.gt => self.quantity).first.inc :stock, -self.quantity # always positive
  end

  def revert_stock!
    kind.inc :stock, self.quantity
  end

  def price
    self.single_price * self.quantity
  end

  def kind
    thing.find_kind self.kind_id
  end

  class<< self
    def build_by_cart_item(order, item)
      order.order_items.build({
        quantity: item.quantity,
        thing: item.thing.id,
        kind_id: item.kind.id,
        single_price: item.kind.price
      })
    end
  end
end
