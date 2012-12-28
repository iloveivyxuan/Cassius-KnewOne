class Step
  include Mongoid::Document

  field :title, type: String
  field :content, type: String
  field :photo_ids, type: Array, default: []

  embedded_in :guide

  def photos
    Photo.find(photo_ids)
  end
end
