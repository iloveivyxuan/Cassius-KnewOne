class QqConnectAuthHandler
  attr_reader :client

  def initialize(info)
  end

  def follow
  end

  def share(content, photo_url = nil)
  end

  def friend_ids(uid, bilateral = false, count = 500)
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def self.parse_image(auth)
    auth[:extra][:raw_info][:figureurl_2] ||auth[:extra][:raw_info][:figureurl_qq_2]
  end
end
