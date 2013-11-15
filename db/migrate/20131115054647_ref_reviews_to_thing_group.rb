class RefReviewsToThingGroup < Mongoid::Migration
  def self.up
    Review.all.each do |r|
      r.thing_group = r.thing.thing_group
      r.save!
    end
  end

  def self.down
  end
end
