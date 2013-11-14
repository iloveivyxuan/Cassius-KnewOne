module AddressesHelper
  def content_for_address(address)
    content = "#{address.province}#{address.district}#{address.street}, #{address.name}"
    content += ", #{address.zip_code}" if address.zip_code.present?
    content += ", #{address.phone}"
    content
  end
end
