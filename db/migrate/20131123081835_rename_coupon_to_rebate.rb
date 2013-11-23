class RenameCouponToRebate < Mongoid::Migration
  def self.up
    orders = Order.all.select {|o| o.coupons.any? }
    orders.each do |o|
      o.coupons.each do |c|
        o.rebates.build name: c.name, price: c.price, note: c.note
      end
      o.coupons.clear
      o.save!
    end
  end

  def self.down
  end
end
