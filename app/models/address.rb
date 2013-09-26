class Address
  include Mongoid::Document
  field :province, type: String
  field :district, type: String
  field :address, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  embedded_in :user
  embedded_in :order

  validates :province, :district, :address, :name, :phone, presence: true

  default_scope -> { order_by(:created_at => :desc) }

  def full
    [self.province, self.district, self.address].compact.join(' ')
  end

  def full_with_contact
    "#{[self.name, self.phone, self.zip_code].compact.join(', ')} #{full}"
  end
end
