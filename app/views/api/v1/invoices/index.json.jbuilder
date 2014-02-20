json.array! @invoices do |invoice|
  json.id invoice.id.to_s
  json.kind invoice.kind
  json.title invoice.title
end
