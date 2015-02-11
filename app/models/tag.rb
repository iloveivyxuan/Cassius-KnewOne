class Tag
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String

  slug do |tag|
    slug = tag.name.to_url
    slug = 'blank' if slug.blank?
    slug
  end

  index name: 1

  validates :name, presence: true, uniqueness: true, length: {maximum: 20}
end
