class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :address
  embeds_many :order_items

  field :state, type: String

  state_machine :state, :initial => :pending do
    state :pending, :paid, :canceled, :shipping, :complete, :refund_pending, :refund_approve, :refund_complete
  end
end
