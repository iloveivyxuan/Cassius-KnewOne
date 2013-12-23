class AddBalanceToUsers < Mongoid::Migration
  def self.up
    User.update_all balance_cents: 0
  end

  def self.down
  end
end
