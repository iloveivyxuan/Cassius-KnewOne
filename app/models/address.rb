class Address
  include Mongoid::Document
  include AreaSelectCn::ActsAsAreaSelectable
  field :district, type: Integer
  field :address, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  belongs_to :user

  acts_as_area_field :district

  def full
    "#{district.area_name ' '} #{address}"
  end
end
