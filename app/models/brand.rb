class Brand
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  field :zh_name, type: String
  field :en_name, type: String
  slug :zh_name, history: true
  slug :en_name, history: true

  field :things_size, type: Integer, default: 0
  before_save :update_count
  before_save :update_things_brand

  mount_uploader :logo, CoverUploader

  has_many :things

  def update_count
    things_size = things.size
  end

  def brand_text
    (zh_name && en_name) ? "#{zh_name}(#{en_name})" : (zh_name || en_name)
  end

  def update_things_brand
    things.each { |thing| thing.update_attributes(brand_name: brand_text) }
  end
end
