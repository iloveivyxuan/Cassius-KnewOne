class Address
  include Mongoid::Document

  field :province_code, type: String
  field :district_code, type: String
  field :city_code, type: String

  field :province, type: String
  field :city, type: String
  field :district, type: String

  field :street, type: String
  field :name, type: String
  field :phone, type: String
  field :zip_code, type: String

  field :default, type: Boolean, default: false

  embedded_in :user
  embedded_in :order
  embedded_in :adoption

  validates :province, :district, :street, :name, :phone, presence: true
  validates :city, presence: true, unless: :persisted? # 约束新的地址，老的地址为兼容不做检查

  default_scope -> { desc(:default) }

  def upgrade_required?
    self.city.blank?
  end

  before_validation do
    if self.province_code.present? && self.province_code != ChinaCity::CHINA
      self.province = ChinaCity.get(self.province_code)
    end

    if self.district_code.present? && self.district_code != ChinaCity::CHINA
      self.district = ChinaCity.get(self.district_code)
    end

    if self.city_code.present? && self.city_code != ChinaCity::CHINA
      self.city = ChinaCity.get(self.city_code)
    end
  end

  after_save do
    if default_changed? && default == true
      user.addresses.each do |address|
        address.update(default: false) if address != self
      end
    end
  end
end
