class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  belongs_to :user
  belongs_to :kind, class_name: 'ThingKind'

  field :quantity, type: Integer, :default => 1

  validates :quantity, :user, :thing, :kind, :presence => true
  validates :quantity, :numericality => {
      only_integer: true,
      greater_than: 0,
      less_than_or_equal_to: Proc.new {|item| item.kind.stock} }

  def price
    self.kind.price * self.quantity
  end
end
