FactoryGirl.define do
  factory :user, aliases: [:author, :sender, :receiver] do
    sequence(:name) { |i| "#{i}-#{Faker::Name.first_name}-#{Faker::Name.last_name}" }
    email { "#{name}@example.com" }
    password 'password'

    before(:create) { |user| user.skip_confirmation! }

    trait :with_addresses do
      after(:create) { |user| create_list(:address, 1, user: user) }
    end

    trait :with_cart_items do
      after(:create) { |user| create_list(:cart_item, 1, user: user) }
    end

    trait :with_invoices do
      after(:create) { |user| create_list(:invoice, 1, user: user) }
    end
  end

  factory :address do
    user
    province '广东省'
    city     '深圳市'
    district { Faker::Address.city }
    street   { Faker::Address.street_address }
    name     { Faker::Address.secondary_address }
    phone    { Faker::PhoneNumber.phone_number }
  end

  factory :thing do
    author
    stage :dsell
    title    { Faker::Lorem.word }
    subtitle { Faker::Lorem.sentence }
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.paragraph}" }
    photo_ids [BSON::ObjectId.new]

    trait :for_sell do
      after(:create) { |thing| create_list(:kind, 1, thing: thing) }
    end
  end

  factory :category do
    sequence(:name) { |i| "#{i} - #{Faker::Lorem.word}" }
  end

  factory :tag do
    sequence(:name) { |i| "#{i} - #{Faker::Lorem.word}" }
  end

  factory :kind do
    thing
    title { '限量版' }
    stage :stock
    stock 100
    sold  0
    price { Faker::Commerce.price }
  end

  factory :cart_item do
    user
    association :thing, factory: [:thing, :for_sell]
    kind_id { thing.kinds.first.id }
    quantity 1
  end

  factory :order do
    user
    address
    state :pending
    deliver_by :sf

    after :create do |order|
      create_list(:order_item, 1, order: order)
      create_list(:invoice, 1, user: order.user)
    end
  end

  factory :order_item do
    association :thing, factory: [:thing, :for_sell]
    kind_id      { thing.kinds.first.id }
    single_price { thing.kinds.first.price }
    quantity 1
  end

  factory :invoice do
    user
    title '个人'
    kind '普通发票'
  end

  factory :review do
    author
    thing
    title   { Faker::Lorem.word }
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.paragraph}" }
  end

  factory :feeling do
    author
    thing
    title   { Faker::Lorem.word }
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.sentence}" }
  end

  factory :story do
    author
    thing
    title   { Faker::Lorem.word }
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.sentence}" }
    occured_at { Time.now }
  end

  factory :group do
    name { Faker::Lorem.word }

    trait :private do
      qualification :private
    end

    trait :with_members do
      after(:create) { |group| create_list(:member, 1, group: group) }
    end
  end

  factory :member do
    ignore do
      user { create(:user) }
    end

    user_id { user.id }

    trait :admin do
      role :admin
    end

    trait :founder do
      role :founder
    end
  end

  factory :topic do
    author
    group
    title   { Faker::Lorem.word }
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.paragraph}" }
  end

  factory :photo do
    image { File.new("#{Rails.root}/app/assets/images/logos/1.png") }
  end

  factory :notification do
    receiver
    type :comment
    context_type :Thing
    context_id { create(:thing).id }
  end

  factory :dialog do
    user
    sender

    after(:create) { |dialog| create_list(:private_message, 1, dialog: dialog) }
  end

  factory :private_message do
    sequence(:content)  { |i| "#{i} - #{Faker::Lorem.sentences}" }
  end

  factory :thing_list do
    author
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }

    after(:create) { |l| create_list(:thing_list_item, 1, thing_list: l) }
  end

  factory :thing_list_item do
    thing
    thing_list
    description { Faker::Lorem.characters(20) }
  end
end
