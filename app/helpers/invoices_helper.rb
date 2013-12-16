module InvoicesHelper
  def content_for_invoice(invoice)
    return '' unless invoice

    "#{invoice.kind} #{invoice.title}"
  end
end
