FactoryGirl.define do
  factory :user, aliases: [:author] do
    sequence(:name) { |i| "#{i}-#{Faker::Name.first_name}-#{Faker::Name.last_name}" }
    email { "#{name}@example.com" }
    password 'password'

    before(:create) { |user| user.skip_confirmation! }
  end

  factory :thing do
    author
    title    { Faker::Lorem.word }
    subtitle { Faker::Lorem.sentence }
    content  { Faker::Lorem.paragraph }
    categories { ["category-#{rand(3)}"] }

  end
end
