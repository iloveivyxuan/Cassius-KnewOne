class StoreOrderPriceInField < Mongoid::Migration
  def self.up
    Order.all.each do |o|
      if o.price.blank?
        if (o.confirmed? || o.paid?) && o.trade_price
          o.price = o.trade_price
        else
          o.sync_price
        end

        o.save :validate => false
      end
    end
  end

  def self.down
  end
end
