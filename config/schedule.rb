# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require 'pathname'

app_path = "#{Pathname.new(__FILE__).realpath.dirname}/../"

set :output, "#{app_path}/log/cron_log.log"

every 1.day, at: '3:00 am' do
  rake 'db:mongoid:remove_undefined_indexes'
  rake 'db:mongoid:create_indexes'
end

every 1.days, :at => '3:30 am' do
  command 'backup perform -t site_backup -r ~/Backup'
end

every 1.day, :at => '3:00 am' do
  runner 'Order.cleanup_expired_orders'
  runner 'Thing.recal_all_related_things'
end

# update thing's brand_name
every 1.day, :at => '3:30 am' do
  runner 'Brand.update_things_brand_name'
end

every 1.day, :at => '4:00 am' do
  rake '-s sitemap:refresh'
end

every 1.day, at: '4:30 am' do
  runner 'Thing.update_all_heat_since(2.years.ago)'
  runner 'ThingList.update_all_heat_since(2.years.ago)'
  runner 'Review.update_all_heat_since(2.years.ago)'
end

every 10.minutes do
  runner 'Thing.update_all_heat_since(20.days.ago)'
  runner 'ThingList.update_all_heat_since(20.days.ago)'
  runner 'Review.update_all_heat_since(20.days.ago)'
end

# categories & tags
every 15.minutes do
  runner 'Tag.update_things_count'
  runner 'Category.update_things_count'
  runner 'Category.update_thing_ids'
end

every 1.day, :at => '1:30 am' do
  runner 'Stat.generate_day_stats'
end

every :monday, :at => '2:00 am' do
  runner "Stat.generate_week_stats"
end

every '0 3 1 * *' do
  runner "Stat.generate_month_stats"
end
