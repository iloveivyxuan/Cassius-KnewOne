if Rails.env.test? || Rails.env.development?
  Faker::Config.locale = 'en-US'
end
