#source 'https://rubygems.org'
source 'http://ruby.taobao.org'
ruby '2.0.0'

# rails and friends
gem 'rails', '~> 4.0.0'
gem 'rails-i18n', '~> 4.0.0'

# database
gem 'mongoid', '>= 4.0.0.alpha1'
gem 'mongoid_slug'
gem 'mongoid_rails_migrations'

# files
gem 'carrierwave'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'carrierwave-upyun'

# configurations
gem 'settingslogic'

# authentications
gem 'devise'
gem 'devise-async'
gem 'omniauth-oauth2', github: 'intridea/omniauth-oauth2'
gem 'omniauth-weibo-oauth2'
gem 'omniauth-twitter'
gem 'weibo_2', github: 'simsicon/weibo_2'
gem 'twitter'
gem 'cancan', github: '3months/cancan', branch: 'strong_parameters', ref: 'b9aa14f'

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
gem 'sass-rails'
gem 'compass-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails', '~> 3.2.1'

# services
gem 'whenever', require: false
gem 'sidekiq'
gem 'mini_magick'

# API
gem 'doorkeeper', github: 'jasl/doorkeeper', branch: 'mongoid4'

# monitoring
gem 'newrelic_rpm'
gem 'airbrake'
gem 'intercom-rails'

# servers
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
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'fabrication'
  gem 'ffaker'
  gem 'database_cleaner'

  # system notifications
  gem 'growl', require: false
  gem 'libnotify', require: false

  # fake email sending
  gem 'letter_opener', github: 'ryanb/letter_opener', branch: 'master'
end
