Devise::Async.setup do |config|
  config.enabled = Rails.env.production? ? true : false
  config.backend = :sidekiq
  config.queue = :mails
end
