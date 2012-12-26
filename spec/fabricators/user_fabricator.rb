Fabricator(:user) do
  email { Faker::Internet.email }
  name  { Faker::Name.first_name }
  password "123456"
end
