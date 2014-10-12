module AddressesHelper
  ADDRESS_SELECT_PROMPTS = {
    province: '- 省/直辖市 -',
    city: '- 城市 -',
    district: '- 地区 -'
  }

  def content_for_address(address)
    return '' unless address

    content = "#{address.province}#{address.district}#{address.street}, #{address.name}"
    content += ", #{address.zip_code}" if address.zip_code.present?
    content += ", #{address.phone}"
    content
  end

  def has_default_address?(user)
    user.addresses.where(default: true).exists? if user
  end

  def address_select(f, address, field, options = {})
    case field
    when :province
      f.select :province_code,
               options_for_select(ChinaCity.list, address.province_code),
               {prompt: '- 省/直辖市 -'}, options
    when :city
      f.select :city_code,
               options_for_select(ChinaCity.list(address.province_code), address.city_code),
               {prompt: '- 城市 -'}, options
    when :district
      f.select :district_code,
               options_for_select(ChinaCity.list(address.city_code), address.district_code),
               {prompt: '- 地区 -'}, options
    else
      ''
    end
  end
end
