class StoreOrderPriceInField < Mongoid::Migration
  def self.up
    Order.all.each do |o|
      o.sync_price
      o.save :validate => false
    end
  end

  def self.down
  end
end
