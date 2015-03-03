require 'kaminari/array_extension'

Kaminari.configure do |config|
  config.default_per_page = 24
  config.max_per_page = 100
  config.max_pages = 50
end
