FactoryGirl.define do
  factory :user do
    sequence(:name) { |i| "#{i}-#{Faker::Name.first_name}-#{Faker::Name.last_name}" }
    email { "#{name}@example.com" }
    password 'password'

    before(:create) { |user| user.skip_confirmation! }
  end
end
