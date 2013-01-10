Fabricator(:photo) do
  image do
    fixture = Rails.root.join("spec/fixtures/example.png")
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(fixture),
      filename: File.basename(File.new(fixture))
    )
  end
end
