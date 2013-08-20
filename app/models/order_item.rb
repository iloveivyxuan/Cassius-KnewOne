class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :order
end
