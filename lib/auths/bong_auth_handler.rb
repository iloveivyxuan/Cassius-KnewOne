class BongAuthHandler
  attr_reader :client

  def initialize(info)
    @client = nil
  end

  def follow
  end

  def share(content, photo_url = nil)
  end

  def topic_wrapper(topic)
  end

  def friend_ids(uid, bilateral = false, count)
    []
  end

  def self.parse_image(auth)
    nil
  end
end
