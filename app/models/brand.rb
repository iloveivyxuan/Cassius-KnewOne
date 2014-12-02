class Brand
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Paranoia
  include Mongoid::Timestamps::Updated

  field :zh_name, type: String
  field :en_name, type: String

  before_save :update_names

  field :country, type: String

  field :things_size, type: Integer, default: 0
  before_save :update_things_size

  field :description, type: String, default: ""

  mount_uploader :logo, CoverUploader

  has_many :things

  field :nickname, type: String, default: ""
  after_save :update_brand_information

  before_save :spacing_description

  def update_things_size
    self.things_size = self.things.size
  end

  def brand_text
    case country
    when "CN"
      brand_text = (zh_name && en_name) ? "#{zh_name} - #{en_name}" : (zh_name || en_name)
    else
      brand_text = en_name
    end
    brand_text.nil? ? zh_name : brand_text
  end

  def tags
    things.map(&:tags).flatten.uniq
  end

  def update_names
    self.zh_name = nil if self.zh_name.try(:empty?)
    self.en_name = nil if self.en_name.try(:empty?)
    self.en_name.strip! if self.en_name
    self.zh_name.strip! if self.zh_name
  end

  def spacing_description
    self.description_will_change!
    self.description.auto_correct!
  end

  include Searchable
  searchable_fields [:zh_name, :en_name, :nickname, :description]

  def self.search(query)
    options = {
      multi_match: {
        query: query,
        fields: ['zh_name^10', 'en_name^10', 'nickname^10', 'description']
      }
    }

    __elasticsearch__.search(query: options)
  end

  def self.update_things_brand_name
    Brand.all.each { |b| b.things.set(brand_name: b.brand_text) }
    Thing.where(brand_id: nil).update_all(brand_name: "")
  end

  def update_brand_information
    if zh_name_changed? || en_name_changed? || nickname_changed?
      self.things.set(brand_information: "#{zh_name} #{en_name} #{nickname}")
    end
  end
end
