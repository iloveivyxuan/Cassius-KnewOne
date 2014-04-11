server 'deployer@staging.knewone.com', roles: %w{web app db}

set :branch, 'staging'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end
