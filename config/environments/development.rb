Making::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Loading the entire application
  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Use a different cache store in production
  config.cache_store = :redis_store, {namespace: "KO", expires_in: 10.minute}

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_dispatch.show_exceptions = true

  # See everything in the log (default is :info)
  config.log_level = :info

  Moped.logger.level = Logger::DEBUG
  Mongoid.logger.level = Logger::DEBUG
end
