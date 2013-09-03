class Address
  include Mongoid::Document
  include DistrictCn::ActsAsAreaField
  field :district, type: String
  field :address, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  belongs_to :user
  validates :district, :address, :name, :phone, presence: true

  acts_as_area_field :district

  def full
    "#{district.area_name ' '} #{address}"
  end

  def full_with_contact
    "#{name}, #{phone}, #{full} #{", #{zip_code}" if zip_code.present?}"
  end
end
