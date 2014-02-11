set :rvm_ruby_string, 'default'
set :rvm_type, :system
require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano-unicorn'
require 'whenever/capistrano'
require 'sidekiq/capistrano'

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

set :keep_releases, 5

set :rails_stage, target[:stage]

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :whenever_command, "bundle exec whenever"
set :whenever_roles, :app

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

after 'deploy:start', 'unicorn:start'
after 'deploy:stop', 'unicorn:stop'
after 'deploy:restart', 'unicorn:restart'
before 'deploy:start', 'deploy:cleanup'

require './config/boot'
require 'airbrake/capistrano'
