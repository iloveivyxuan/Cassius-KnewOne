Fabricator(:guide) do
  author(fabricator: :user)
  title "Guide Title"
  steps(count: 3) do |attrs, i|
    Fabricate.build(:step, title: "title-#{i}", content: "content-#{i}")
  end
end
