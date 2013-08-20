class CartItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :thing
  belongs_to :user

  field :quantity, type: Integer, :default => 1
  field :kind_id, type: String

  validates :quantity, :user, :thing, :kind_id, :presence => true
  validates :quantity, :numericality => { only_integer: true, greater_than: 0 }

  def kind
    thing.kinds.selling.find(self.kind_id)
  end
end
