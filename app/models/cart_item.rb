class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  belongs_to :user

  field :quantity, type: Integer, :default => 1
  field :kind, type: String

  validates :quantity, :thing, :user, :presence => true
  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  attr_accessible :quantity, :thing, :kind
end
