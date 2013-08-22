class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer

  belongs_to :thing_kind

  embedded_in :order

  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  def claim_stock!
    thing_kind.inc :stock, -self.quantity # always positive
  end

  def revert_stock!
    thing_kind.inc :stock, self.quantity
  end
end
