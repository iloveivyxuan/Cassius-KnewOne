puts "Create users: "
password = "123456"
10.times do
  u = User.create! name: Faker::Name.first_name,
  email: Faker::Internet.email,
  password: password,
  password_confirmation: password
  puts "#{u.email} #{u.name}"
end
puts "Users created, all passwords are #{password}"

puts "Create guides: "
User.all.each do |user|
  puts "guides for #{user.name}"
  rand(10).times do
    guide = Guide.new(author: user, title: Faker::Lorem.sentence)
    puts "#{guide.author.name} #{guide.title}"
    (rand(5)+1).times do
      step = Step.new(title: Faker::Lorem.sentence, content: Faker::Lorem.paragraph)
      puts "  step #{step.title}"
      guide.steps << step
    end
    guide.save!
  end
end
puts "Guides created"
