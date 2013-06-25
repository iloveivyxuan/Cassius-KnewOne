set :rvm_ruby_string, 'default'
set :rvm_type, :system
require "rvm/capistrano"
require 'bundler/capistrano'
require 'capistrano-unicorn'

server_list = {
  'production' => {host: '106.186.20.196', branch: 'master', stage: 'production'},
  'staging' => {host: '61.174.15.157', branch: 'staging', stage: 'staging'}
}

target = server_list[ENV['STAGE'] || 'production']

server target[:host], :web, :app, :db, primary: true

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
after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  namespace :assets do
    desc "Clean expired assets."
    task :clean_expired, roles: assets_role, except: {no_release: true} do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean_expired"
    end
  end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end

after 'deploy:start', 'unicorn:start'
after 'deploy:stop', 'unicorn:stop'
after 'deploy:restart', 'unicorn:restart'

require './config/boot'
require 'airbrake/capistrano'
