#source 'https://rubygems.org'
source 'http://ruby.taobao.org'
ruby '2.0.0'

# rails and friends
gem 'rails', '~> 3.2.13'
gem 'rails-i18n'
# database
gem 'mongoid', '~> 3.1.5'
gem 'mongoid_slug'
gem 'mongoid_taggable'
gem 'mongoid_rails_migrations'
# components
gem 'simple_form'
gem 'nested_form'
gem 'kaminari'
gem 'rinku'
# views
gem 'slim-rails'
gem 'jbuilder'
# javascripts
gem 'jquery-rails'
gem 'backbone-on-rails'
# file uploads
gem 'carrierwave'
gem 'carrierwave-mongoid'
gem 'carrierwave-upyun'
# authentications
gem 'devise'
gem 'omniauth-weibo-oauth2'
gem 'weibo_2'
gem 'omniauth-twitter'
gem 'twitter'
gem 'cancan'
# configurations
gem 'settingslogic'
# monitoring
gem 'newrelic_rpm'
gem 'airbrake'
gem 'intercom-rails', '~> 0.2.21'
# crontab
gem 'whenever', require: false
gem 'jasl_tenpay', github: 'jasl/tenpay'
gem 'alipay'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'modernizr-rails'
  gem 'uglifier'
  # gem 'turbo-sprockets-rails3' # seems bug with ruby 2.0
  gem 'therubyracer'

  # components
  gem 'jquery-fileupload-rails'
  gem 'handlebars_assets'

  # stylesheets library
  gem 'compass-rails'
  gem 'bootstrap-sass', '~> 2.3.2'
  gem 'font-awesome-rails', '~> 3.2.1'
end

group :production do
  gem 'unicorn'
end

group :development do
  gem 'quiet_assets'
  gem 'thin'

  # deploy
  gem 'capistrano', '~> 2.15.0'
  gem 'rvm-capistrano'
  gem 'capistrano-unicorn'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem 'jasminerice'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-jasmine'
  gem 'guard-livereload'
  gem 'fabrication'
  gem 'ffaker'
  gem 'database_cleaner'

  # file system handling
  # please don't develop at windows
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false

  # system notifications
  gem 'growl', require: false
  gem 'libnotify', require: false

  # fake email sending
  gem 'letter_opener'
end
