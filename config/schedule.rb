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
  rake 'db:create_indexes'
end

every 1.days, :at => '3:30 am' do
  command 'backup perform -t site_backup -r ~/Backup'
end

every 1.day, :at => '3:00 am' do
  runner 'Order.cleanup_expired_orders'
  runner 'Thing.recal_all_related_things'
end

every 1.day, :at => '4:00 am' do
  rake '-s sitemap:refresh'
end

every 1.day, at: '4:30 am' do
  runner 'Thing.update_all_heat_since(2.years.ago)'
  runner 'Review.update_all_heat_since(2.years.ago)'
end

every 10.minutes do
  runner 'Thing.update_all_heat_since(20.days.ago)'
  runner 'Review.update_all_heat_since(20.days.ago)'
end

every 1.day, :at => '1:00 pm' do
  runner 'Stat.generate_stats'
end
