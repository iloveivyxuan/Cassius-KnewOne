atom_feed language: "zh-CN" do |feed|
  feed.title @thing.title
  # feed.updated @reviews.first.created_at if @reviews.length > 0

  # @reviews.each do |review|
  #   feed.entry review, url: thing_review_url(@thing, review) do |entry|
  #     entry.title review.title
  #     entry.content review.content, type: 'html'
  #     entry.author do |author|
  #       author.name review.author.name
  #     end
  #   end
  # end
end
