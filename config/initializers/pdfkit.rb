PDFKit.configure do |config|
  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  config.default_options = {
      :page_size => 'A4',
      :print_media_type => true,
      :margin_top => '10mm',
      :margin_bottom => '10mm',
      :margin_left => '20mm',
      :margin_right => '20mm'
  }
  # Use only if your external hostname is unavailable on the server.
  # config.root_url = "http://localhost"
end
