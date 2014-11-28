class Article < Post
  field :summary, type: String
  field :photo, type: Hash, default: {}
end
