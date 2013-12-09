class SetExsistenceUsersStatusToInitial < Mongoid::Migration
  def self.up
    User.all.each do |u|
      u.status = :initial
      u.save
    end
  end

  def self.down
  end
end
