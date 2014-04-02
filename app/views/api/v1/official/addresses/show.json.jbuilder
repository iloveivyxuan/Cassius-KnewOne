json.id @address.id.to_s
json.partial! 'api/v1/official/addresses/address', address: @address
