# lock '3.1.0'

set :application, 'making'
set :user, 'deployer'
set :repo_url, 'git@github.com:KnewOneCom/knewone.git'
set :deploy_to, "/home/deployer/apps/making"
set :pty, true
set :ssh_options, { forward_agent: true }
set :log_level, :debug
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :linked_files, %w{config/application.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rvm_type, :system
set :bundle_bins, %w(gem rake rails whenever)
set :whenever_roles, :app

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [2, 16]
set :puma_workers, 8
set :puma_worker_timeout, nil
set :puma_init_active_record, false
set :puma_preload_app, false
set :puma_prune_bundler, true
set :puma_default_hooks, false

namespace :deploy do
  after :check, 'puma:check'
  after :updated, 'newrelic:notice_deployment'
  after :publishing, :restart
  after :finishing, :cleanup
end
