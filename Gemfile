#source 'https://rubygems.org'
source 'http://ruby.taobao.org'

# rails and friends
gem 'rails', '~> 3.2.13'
gem 'rails-i18n'
# database
gem 'mongoid'
gem 'mongoid_slug'
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
gem 'modernizr-rails'
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

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'turbo-sprockets-rails3'
  gem 'therubyracer'

  # components
  gem 'jquery-fileupload-rails'
  gem 'handlebars_assets'

  # stylesheets library
  gem 'compass-rails'
  gem 'bootstrap-sass'
  gem 'font-awesome-rails'
end

group :production do
  gem 'unicorn'
end

group :development do
  gem 'quiet_assets'
  gem 'thin'

  # deploy
  gem 'capistrano'
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

  gem 'pry-rails'

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
