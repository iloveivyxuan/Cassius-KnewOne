server 'deployer@knewone.com', roles: %w{web app db}

set :branch, 'master'

set :rails_env, 'production'

namespace :deploy do
  task :restart do
    invoke 'unicorn:reload'
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
