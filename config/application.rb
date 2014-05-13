require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Making
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib
                                #{config.root}/lib/auths
                                #{config.root}/lib/waybill
                                #{config.root}/lib/mongoid
                                #{config.root}/lib/alipay)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-CN"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure exception handling via route
    config.exceptions_app = self.routes if Rails.env.production?

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # add fonts to assets paths
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    #Suppress Assets, Spec Tests and Helpers for views and helpers
    config.generators do |g|
      g.assets false
      g.view_specs false
      g.test_framework      :rspec, fixture: true
      g.fixture_replacement :fabrication
    end

    config.action_view.sanitized_allowed_tags = ['embed', 'iframe', 'strike', 'u']
    config.action_view.sanitized_allowed_attributes = ['src', 'height', 'width', 'target']

    I18n.enforce_available_locales = false

    config.to_prepare do
      Doorkeeper::ApplicationController.send :include, ApplicationHelper
      # Base layout. Uses app/views/layouts/my_layout.html.erb
      # Doorkeeper::ApplicationController.layout "my_layout"

      # Only Applications list
      # Doorkeeper::ApplicationsController.layout "my_layout"

      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "oauth"

      # Only Authorized Applications
      # Doorkeeper::AuthorizedApplicationsController.layout "doorkeeper"
    end
  end
end
