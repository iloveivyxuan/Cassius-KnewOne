server 'deployer@staging.knewone.com', roles: %w{web app db}

set :branch, 'staging'

set :rails_env, 'staging'

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end
