class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :thing_title, type: String
  field :kind_title, type: String
  field :quantity, type: Integer
  field :single_price, type: BigDecimal

  belongs_to :thing
  field :kind_id, type: String
  validates :kind_id, :presence => true

  embedded_in :order

  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  def claim_stock!
    # protect race condition, over selling should throw nil error
    thing.kinds.where(:id => self.kind_id, :stock.gte => self.quantity).first.inc :stock, -self.quantity # always positive
  end

  def revert_stock!
    kind.inc :stock, self.quantity
  end

  def price
    self.single_price * self.quantity
  end

  def kind
    if k = thing.kinds.where(_id: self.kind_id).first
      k
    else
      thing.kinds.new title: "*已下架*#{self.kind_title}"
    end
  end

  def thing_name
    self.thing_title || thing.title
  end

  def kind_name
    self.kind_title || kind.title
  end

  class<< self
    def build_by_cart_item(order, item)
      return unless item.legal? && item.has_enough_stock?

      order.order_items.build({
        thing_title: item.thing.title,
        kind_title: item.kind.title,
        quantity: item.quantity,
        thing: item.thing.id,
        kind_id: item.kind.id,
        single_price: item.kind.price
      })
    end
  end
end
