class OrderItem
  include Mongoid::Document

  field :thing_title, type: String
  field :kind_title, type: String
  field :quantity, type: Integer
  field :single_price, type: BigDecimal

  belongs_to :thing
  field :kind_id, type: String
  validates :kind_id, :presence => true

  scope :by_id, ->(id) { where 'thing_id' => id }

  embedded_in :order

  validates :quantity, :numericality => {only_integer: true, greater_than: 0}

  validates :quantity, :single_price, presence: true

  def claim_stock!
    # protect race condition, over selling should throw nil error
    thing.kinds.where(id: kind_id, :stock.gte => quantity).first.inc stock: -self.quantity, sold: self.quantity
  end

  def revert_stock!
    kind.inc stock: self.quantity, sold: -self.quantity
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

  def name
    "#{thing_name}-#{kind_name}"
  end
end
