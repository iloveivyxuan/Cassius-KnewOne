server 'deployer@staging.knewone.com', roles: %w{web app db}

set :branch, 'staging'

set :rails_env, 'staging'

set :ssh_options, { port: 22222, forward_agent: true }

set :unicorn_config_path, File.join(current_path, "config", "unicorn", "#{fetch(:rails_env)}.rb")

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end
