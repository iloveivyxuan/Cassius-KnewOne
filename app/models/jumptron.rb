class Jumptron
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = [:normal, :landing]

  field :alt, type: String
  field :href, type: String
  field :default, type: Boolean, default: false
  field :type, type: Symbol

  mount_uploader :image, ImageUploader

  validates :image, presence: true, file_size: {maximum: 8.megabytes.to_i}
  validates :type, inclusion: {in: Jumptron::TYPE}

  scope :by_type, -> (type) do
    type_sym = type.to_sym
    if type_sym == :normal
      where(:type.in => [type_sym, nil])
    else
      where(type: type_sym)
    end
  end

end
