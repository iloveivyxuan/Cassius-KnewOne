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

  field :description, type: String, default: ""

  mount_uploader :logo, CoverUploader

  alias_method :cover, :logo

  has_many :things

  field :nickname, type: String, default: ""
  after_save :update_brand_information

  before_save :spacing_description

  after_save :update_things_size

  def brand_text
    case country
    when "CN"
      brand_text = full_name
    else
      brand_text = en_name
    end
    brand_text.nil? ? zh_name : brand_text
  end

  def full_name
    (zh_name && en_name) ? "#{zh_name} - #{en_name}" : (zh_name || en_name)
  end

  def categories
    category_ids = things.map(&:category_ids).flatten.uniq
    Category.third_level.in(id: category_ids)
  end

  def spacing_description
    self.description_will_change!
    self.description.auto_correct!
  end

  include Searchable

  searchable_fields [:zh_name, :en_name, :nickname]

  mappings do
    indexes :en_name, copy_to: :ngram
    indexes :ngram, index_analyzer: 'english', search_analyzer: 'standard'
  end

  alias_method :_as_indexed_json, :as_indexed_json
  def as_indexed_json(options={})
    _as_indexed_json(options).merge(brand_text: brand_text)
  end

  def self.search(query)
    options = {
      multi_match: {
        query: query,
        fields: ['zh_name^10', 'en_name^10', 'nickname^10', 'ngram^3']
      }
    }

    __elasticsearch__.search(query: options, min_score: 1)
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

  private

  def update_names
    self.unset(:zh_name) if self.zh_name.blank?
    self.unset(:en_name) if self.en_name.blank?
    self.set(en_name: self.en_name.strip) if self.en_name
    self.set(zh_name: self.zh_name.strip) if self.zh_name
  end

  def update_things_size
    set(things_size: things.size)
  end
end
