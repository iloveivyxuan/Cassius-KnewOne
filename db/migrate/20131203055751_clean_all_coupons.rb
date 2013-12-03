class CleanAllCoupons < Mongoid::Migration
  def self.up
    Coupon.destroy_all
  end

  def self.down
  end
end
