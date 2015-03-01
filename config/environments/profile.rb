Making::Application.configure do
  config.eager_load = true
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = true
end
