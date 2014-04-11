lock '3.1.0'

set :application, 'making'
set :user, 'deployer'
set :repo_url, 'git@github.com:lilu/making.git'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :pty, true
set :ssh_options, { forward_agent: true }
set :log_level, :info
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :linked_files, %w{config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rvm_type, :system
set :bundle_bins, fetch(:bundle_bins, []).push %w(whenever)
set :whenever_roles, :app

namespace :deploy do
  after :publishing, :restart
  after :finishing, :cleanup
end
