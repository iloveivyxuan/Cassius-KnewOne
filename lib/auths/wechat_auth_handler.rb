class WechatAuthHandler
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

  def friend_ids(uid, count)
    []
  end

  def self.parse_image(auth)
  end
end
