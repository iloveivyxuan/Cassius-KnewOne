class FixThingGroupMigration < Mongoid::Migration
  def self.up
    Thing.all.each do |t|
      tg = t.thing_group
      if tg.nil?
        puts '----'
        puts t.title
        puts t.id
        puts 'tg is nil!!!'
        t.build_thing_group(founder: t.author, name: t.title).save
        next
      end

      ThingGroup.where(name: tg.name).reject {|g| g == tg}.each do |g|
        g.reviews.each do |r|
          tg.reviews<< r
        end
        g.destroy
      end
    end
  end

  def self.down
  end
end
