class Article < Post
  mount_uploader :cover, CoverUploader
  field :summary, type: String
end
