source 'https://rubygems.org'
ruby '2.1.1'

# rails and friends
gem 'rails', '~> 4.1.0'
gem 'rails-i18n'

# database
gem 'mongoid', '>= 4.0.0.alpha1'
gem 'mongoid_slug'

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
gem 'weibo_2', github: 'simsicon/weibo_2'
gem 'twitter', '>= 5.8.0'
gem 'cancancan', '~> 1.7.0'

# payment
gem 'jasl_tenpay', github: 'jasl/tenpay'
gem 'alipay'

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
gem 'coffee-rails'
gem 'backbone-on-rails'
gem 'modernizr-rails'
gem 'jquery-fileupload-rails'
gem 'handlebars_assets'

# stylesheets
gem 'sass-rails', '~> 4.0.3' # Resolve dependency with sprocket
gem 'compass-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails', github: 'bokmann/font-awesome-rails'

# services
gem 'whenever', require: false
gem 'sinatra', '>= 1.3.0', require: false
gem 'sidekiq'
gem 'mini_magick'

# API
gem 'doorkeeper', github: 'doorkeeper-gem/doorkeeper'

# monitoring
gem 'newrelic_rpm'
gem 'airbrake'
gem 'intercom-rails'

# sitemap
gem 'sitemap_generator'

# misc
gem 'nokogiri'
gem 'browser'

# cache
gem 'redis-rails'

# servers
group :production do
  gem 'unicorn'
end

group :development do
  gem 'quiet_assets'
  gem 'thin'
  gem 'spring'

  # deploy
  gem 'capistrano', '~> 3.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-sidekiq', require: false
end

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-livereload', github: 'guard/guard-livereload'
  gem 'fabrication'
  gem 'ffaker'
  gem 'database_cleaner'

  # system notifications
  gem 'growl', require: false
  gem 'libnotify', require: false

  # fake email sending
  gem 'letter_opener', github: 'ryanb/letter_opener', branch: 'master'
end
