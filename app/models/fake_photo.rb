class FakePhoto
  def initialize(url)
    @url = url
  end

  def url(version = nil)
    version ? "#{@url}!#{version}" : @url
  end
end
