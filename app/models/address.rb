class Address
  include Mongoid::Document
  field :district, type: Integer
  field :address, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  belongs_to :user

  def area
    AreaSelectCn::Id.new(self.district).area_name(default = '-')
  end

  attr_accessible :district, :address, :name, :phone, :zip_code
end
