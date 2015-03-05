server 'deployer@staging.knewone.com', roles: %w{web app db}

set :branch, 'staging'

set :rails_env, 'staging'

set :ssh_options, { port: 22222, forward_agent: true }

set :puma_threads, [2, 8]
set :puma_workers, 2
