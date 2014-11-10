source 'https://ruby.taobao.org'
ruby '2.1.2'

# rails and friends
gem 'rails', '~> 4.1.0'
gem 'rails-i18n'

# database
gem 'mongoid', '>= 4.0.0.alpha1'
gem 'mongoid_slug'
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
gem 'modernizr-rails'
gem 'jquery-fileupload-rails'
gem 'handlebars_assets'
gem 'x-editable-rails', github: 'werein/x-editable-rails'
gem 'china_city'

# stylesheets
gem 'sass-rails', '~> 4.0.3' # Resolve dependency with sprocket
gem 'compass-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails', github: 'bokmann/font-awesome-rails'
gem "autoprefixer-rails"

# services
gem 'whenever', require: false
gem 'sinatra', '>= 1.3.0', require: false
gem 'sidekiq'
gem 'mini_magick'
gem 'apn_sender', require: ['apn', 'apn/jobs/sidekiq_notification_job']

# API
gem 'doorkeeper', '~> 1', github: 'doorkeeper-gem/doorkeeper'

# monitoring
gem 'newrelic_rpm'
gem 'airbrake'

# sitemap
gem 'sitemap_generator'

# misc
gem 'nokogiri'
gem 'browser'
gem 'dkim'

# cache
gem 'redis-rails'

# resolve error like ArgumentError: invalid byte sequence in UTF-8
gem 'rack-utf8_sanitizer'

# servers
group :production do
  gem 'unicorn'
end

group :development do
  gem 'quiet_assets'
  gem 'thin'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'meta_request'

  # deploy
  gem 'capistrano', '~> 3.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-sidekiq', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'pry-rails'
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
