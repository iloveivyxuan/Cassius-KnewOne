class Address
  include Mongoid::Document
  field :province, type: String
  field :district, type: String
  field :street, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  embedded_in :user
  embedded_in :order

  validates :province, :district, :street, :name, :phone, presence: true

  default_scope desc(:created_at)
end
