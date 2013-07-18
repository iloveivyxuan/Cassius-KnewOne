set :rvm_ruby_string, 'default'
set :rvm_type, :system
require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano-unicorn'

SERVER_LIST = {
  'staging' => {host: '106.186.20.196', branch: 'staging', stage: 'staging'},
  'production' => {host: '61.174.15.157', branch: 'master', stage: 'production'}
}
env = ENV['STAGE'] || 'production'

target = SERVER_LIST[env]

server target[:host], :web, :app, :db, primary: true

set :rails_env, env

set :application, "making"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:lilu/making.git"
set :branch, target[:branch]

set :rails_stage, target[:stage]

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{target[:branch]}`
      puts "WARNING: HEAD is not the same as origin/#{target[:branch]}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end

namespace :customer_service do
  desc "Start customer service"
  task :start, :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake websocket_rails:start_server RAILS_ENV=#{rails_stage}")
  end

  desc "Stop customer service"
  task :stop, :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake websocket_rails:stop_server RAILS_ENV=#{rails_stage}")
  end

  desc "Restart customer service"
  task :stop, :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake websocket_rails:stop_server RAILS_ENV=#{rails_stage}")
    run("cd #{deploy_to}/current && /usr/bin/env rake websocket_rails:start_server RAILS_ENV=#{rails_stage}")
  end
end

after 'deploy:start', 'customer_service:start'
after 'deploy:stop', 'customer_service:stop'
after 'deploy:restart', 'customer_service:restart'

after 'deploy:start', 'unicorn:start'
after 'deploy:stop', 'unicorn:stop'
after 'deploy:restart', 'unicorn:restart'

require './config/boot'
require 'airbrake/capistrano'
