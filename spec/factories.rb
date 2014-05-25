FactoryGirl.define do
  factory :user, aliases: [:author] do
    sequence(:name) { |i| "#{i}-#{Faker::Name.first_name}-#{Faker::Name.last_name}" }
    email { "#{name}@example.com" }
    password 'password'

    before(:create) { |user| user.skip_confirmation! }

    trait :with_addresses do
      after(:create) { |user| create_list(:address, rand(1..2), user: user) }
    end

    trait :with_invoices do
      after(:create) { |user| create_list(:invoice, rand(1..2), user: user) }
    end
  end

  factory :address do
    user
    province '广东省'
    district { Faker::Address.city }
    street   { Faker::Address.street_address }
    name     { Faker::Address.secondary_address }
    phone    { Faker::PhoneNumber.phone_number }
  end

  factory :thing do
    author
    title    { Faker::Lorem.word }
    subtitle { Faker::Lorem.sentence }
    content  { Faker::Lorem.paragraph }
    categories { ["category-#{rand(3)}"] }

    trait :for_sell do
      after(:create) { |thing| create_list(:kind, 1, thing: thing) }
    end
  end

  factory :kind do
    thing
    title { '限量版' }
    stage :stock
    stock { rand(0..100) }
    sold  { rand(0..100) }
    price { Faker::Commerce.price }
  end

  factory :order do
    user
    address
    state :pending
    deliver_by :sf
  end

  factory :invoice do
    user
    title '个人'
    kind '普通发票'
  end
end
