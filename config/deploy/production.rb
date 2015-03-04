server 'deployer@knewone.com', roles: %w{web app db}

set :branch, 'master'

set :rails_env, 'production'

set :ssh_options, { port: 22222, forward_agent: true }

namespace :deploy do
  before :starting, :before_start_deploy
  before :updating, :test
  after :finished, 'airbrake:deploy'
  after :finished, :after_finish_deploy
  task :restart do
    invoke 'puma:smart_restart'
    invoke 'sidekiq:restart'
  end
end

namespace :sitemap do
  desc 'Generate new sitemap and ping to search engine'
  task :refresh do
    on roles(:app) do
      execute :rake, 'sitemap:refresh'
    end
  end
end
