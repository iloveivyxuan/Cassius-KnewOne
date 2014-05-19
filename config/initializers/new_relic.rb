if Rails.environment.production? && defined?(Unicorn) && File.basename($0).start_with?('unicorn')
  ::NewRelic::Agent.manual_start()
  ::NewRelic::Agent.after_fork(:force_reconnect => true)
end
