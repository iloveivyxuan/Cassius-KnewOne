json.array!(@reviews) do |review|
  json.title review.title
  json.url thing_review_url(params[:thing_id], review, :format => :json)
  json.score review.score
  json.content review.content
  json.author do
    json.avatar review.author.avatar.url(:small)
    json.id review.author.id
    json.name review.author.name
  end
end
