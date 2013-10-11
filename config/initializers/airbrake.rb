if Rails.env.production?
  Airbrake.configure do |config|
    config.api_key = 'c7ac118b281cc0cb99161502acb712e3'
  end
end
