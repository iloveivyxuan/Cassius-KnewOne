class PhotoDecorator < Draper::Base
  include Draper::LazyHelpers
  decorates :photo

  def to_jq_upload
    {
      id:   model.id.to_s,
      name: model.name,
      size: model.size,
      url:  model.url,
      thumbnail_url:  model.url(:small),
      delete_url:  photo_path(model),
      delete_type: "DELETE"
    }
  end
end
