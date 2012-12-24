source 'https://rubygems.org'

# rails and friends
gem 'rails'
gem 'rails-i18n'
# database
gem 'mongoid'
gem 'mongoid_slug'
# components
gem 'simple_form'
gem 'kaminari'
# presenters and views
gem 'slim-rails'
gem 'jquery-rails'
gem 'jbuilder'
# file uploads
gem 'carrierwave'
gem 'carrierwave-mongoid'
gem 'carrierwave-upyun'
# authentications
gem 'devise'
gem 'cancan'
# configurations
gem 'settingslogic'
# exception notificaton
gem "airbrake"

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'turbo-sprockets-rails3'

  # components
  gem "jquery-fileupload-rails"

  # stylesheets library
  gem 'compass-rails'
  gem 'bootstrap-sass'
  gem 'font-awesome-sass-rails'
end

group :production do
  gem 'unicorn'
end

group :development do
  gem 'thin'
  gem 'quiet_assets'

  # deploy
  gem 'capistrano'
  gem 'rvm-capistrano'
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
end
