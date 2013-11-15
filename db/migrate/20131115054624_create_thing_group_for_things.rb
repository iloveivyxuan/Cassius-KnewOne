class CreateThingGroupForThings < Mongoid::Migration
  def self.up
    Thing.all.each do |t|
      begin
        t.content = t.title unless t.content.present?
        t.build_thing_group(founder: t.author, name: t.title).save!

        t.save!
      rescue
        puts t.errors.full_messages
      end
    end
  end

  def self.down
  end
end
