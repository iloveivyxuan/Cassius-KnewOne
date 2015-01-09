server 'deployer@knewone.com', roles: %w{web app db}

set :branch, 'master'

set :rails_env, 'production'

set :ssh_options, { port: 22222, forward_agent: true }

set :unicorn_config_path, File.join(current_path, "config", "unicorn", "#{fetch(:rails_env)}.rb")

namespace :deploy do
  before :starting, :before_start_deploy
  before :updating, :test
  after :finished, 'airbrake:deploy'
  after :finished, :after_finish_deploy
  after :finished, :show_version
  task :restart do
    invoke 'unicorn:reload'
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
