json.array! @addresses do |address|
  json.id address.id.to_s
  json.province address.province
  json.district address.district
  json.street address.street
  json.zip_code address.zip_code if address.zip_code.present?
  json.phone address.phone
end
