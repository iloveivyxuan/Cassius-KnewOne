module AddressesHelper
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
end
