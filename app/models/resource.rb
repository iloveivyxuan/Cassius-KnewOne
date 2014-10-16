class Resource
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  field :url, type: String
  field :deliver_price, type: BigDecimal, default: 0

  has_many :things
end
