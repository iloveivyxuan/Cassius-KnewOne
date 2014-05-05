class Address
  include Mongoid::Document
  field :province, type: String
  field :district, type: String
  field :street, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String
  field :default, type: Boolean, default: false

  embedded_in :user
  embedded_in :order

  validates :province, :district, :street, :name, :phone, presence: true
  validates_inclusion_of :province, in: Province.keys

  default_scope -> { desc(:default, :created_at) }
end
