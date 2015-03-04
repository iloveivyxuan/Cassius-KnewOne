server 'deployer@staging.knewone.com', roles: %w{web app db}

set :branch, 'staging'

set :rails_env, 'staging'

set :ssh_options, { port: 22222, forward_agent: true }
