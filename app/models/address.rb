class Address
  include Mongoid::Document
  field :province, type: String
  field :district, type: String
  field :city, type: String
  field :street, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String
  field :default, type: Boolean, default: false

  embedded_in :user
  embedded_in :order
  embedded_in :adoption

  validates :province, :district, :street, :name, :phone, presence: true
  validates_inclusion_of :province, in: Province.keys

  default_scope -> { desc(:default, :created_at) }

  after_save do
    if default_changed? && default == true
      user.addresses.each do |address|
        address.update(default: false) if address != self
      end
    end
  end
end
