if Rails.env.profile?
  Rack::MiniProfiler.config.authorization_mode = :allow_all
  Rack::MiniProfiler.config.skip_paths << Rails.application.config.assets.prefix
end
