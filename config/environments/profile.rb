Making::Application.configure do
  config.eager_load = true
  config.cache_classes = false
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :redis_store, {namespace: "KO", expires_in: 1.hour}
  config.action_dispatch.show_exceptions = true
end
