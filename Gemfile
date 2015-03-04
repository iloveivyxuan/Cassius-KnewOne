source 'https://ruby.taobao.org'
ruby '2.2.1'

# rails and friends
gem 'rails', '~> 4.2.0'
gem 'rails-i18n'

# database
gem 'mongoid', '>= 4.0.0.alpha1'
gem 'mongoid-slug'
gem 'mongoid_paranoia'

# files
gem 'carrierwave'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'carrierwave-upyun'

# configurations
gem 'settingslogic'

# authentications
gem 'devise'
# gem 'devise-async'
gem 'omniauth-oauth2', github: 'intridea/omniauth-oauth2'
gem 'omniauth-weibo-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-wechat', github: 'jasl/omniauth-wechat'
gem 'omniauth-qq-oauth2', github: 'sunbo/omniauth-qq-oauth2'
gem 'omniauth-douban-oauth2'
gem 'weibo_2', github: 'jasl/weibo_2'
gem 'twitter', '>= 5.8.0'
gem 'cancancan', '~> 1.7.0'

# payment
gem 'jasl_tenpay', github: 'jasl/tenpay'
gem 'alipay'
gem 'wx_pay', github: 'jasl/wx_pay'

# components
gem 'simple_form'
gem 'nested_form'
gem 'kaminari'
gem 'rinku'

# views
gem 'slim-rails'
gem 'jbuilder'

# assets
gem 'uglifier'
gem 'therubyracer'

# javascripts
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'coffee-rails'
gem 'backbone-on-rails'
gem 'marionette-rails'
gem 'jquery-fileupload-rails'
gem 'handlebars_assets'
gem 'x-editable-rails', github: 'werein/x-editable-rails'
gem 'china_city'
gem 'rails-timeago'

# stylesheets
gem 'sass-rails'
gem 'compass-rails'
gem 'bootstrap-sass'
gem "autoprefixer-rails"

# services
gem 'whenever', require: false
gem 'sinatra', '>= 1.3.0', require: false
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'mini_magick'
gem 'apn_sender', require: ['apn', 'apn/jobs/sidekiq_notification_job']

# search
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# API
gem 'doorkeeper', '~> 1', github: 'doorkeeper-gem/doorkeeper'

# monitoring
gem 'newrelic_rpm'
gem 'newrelic_moped'
gem 'newrelic-redis'
gem 'airbrake'

# sitemap
gem 'sitemap_generator'

# misc
gem 'responders', '~> 2.0'
gem 'nokogiri'
gem 'browser'
gem 'dkim'

# cache
gem 'redis-rails'

# resolve error like ArgumentError: invalid byte sequence in UTF-8
gem 'rack-utf8_sanitizer'

# adding spaces between Chinese characters & English characters
gem 'auto-correct'

# countries
gem 'country_select'

# similarity
gem 'similar_text'

# servers

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'thin'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'meta_request'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-doc'
  gem 'web-console', '~> 2.0'

  # deploy
  gem 'capistrano', '~> 3.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-sidekiq', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'mongoid-rspec'
  gem 'guard-rspec'
  gem 'guard-livereload', github: 'guard/guard-livereload'
  gem 'faker'
  gem 'database_cleaner'

  # system notifications
  gem 'growl', require: false
  gem 'libnotify', require: false

  # fake email sending
  gem 'letter_opener', github: 'ryanb/letter_opener', branch: 'master'
end
