class Brand
  include Mongoid::Document
  include Mongoid::Slug

  field :zh_name, type: String
  field :en_name, type: String

  field :things_size, type: Integer, default: 0
  before_save :update_things_size
  before_save :update_names

  field :description, type: String, default: ""

  mount_uploader :logo, CoverUploader

  has_many :things

  def update_things_size
    self.things_size = self.things.size
  end

  def brand_text
    (zh_name && en_name) ? "#{zh_name}(#{en_name})" : (zh_name || en_name)
  end

  def tags
    things.map(&:tags).flatten.uniq
  end

  def update_names
    self.zh_name = nil if self.zh_name.try(:empty?)
    self.en_name = nil if self.en_name.try(:empty?)
  end
end
