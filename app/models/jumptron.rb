class Jumptron
  include Mongoid::Document
  include Mongoid::Timestamps

  field :alt, type: String
  field :href, type: String
  field :default, type: Boolean, default: false
  field :jumptron_type, type: Integer, default: 1

  mount_uploader :image, ImageUploader

  validates :image, presence: true, file_size: {maximum: 8.megabytes.to_i}

  scope :with_type, -> (type) do
    type_value = Jumptron::TYPE.fetch(type)
    if type_value == 1
      where(:jumptron_type.in => [Jumptron::TYPE.fetch(type), nil])
    else
      where(jumptron_type: Jumptron::TYPE.fetch(type))
    end
  end

  TYPE = {
    normal: 1,
    landing: 2
  }

end
