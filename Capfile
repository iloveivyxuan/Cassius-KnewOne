require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/sidekiq'
require 'capistrano/sidekiq/monit'
require 'whenever/capistrano'
require 'airbrake/capistrano3'
require 'new_relic/recipes'

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
