class TwitterAuthHandler
  attr_reader :client

  def initialize(info)
    @client = Twitter::REST::Client.new do |config|
      config.access_token = info[:access_token]
      config.access_token_secret = info[:access_secret]
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
    end

    if Settings.kexue.enable
      @client.connection_options.merge! proxy: Settings.kexue.proxy
    end
  end

  def follow
    client.follow Settings.twitter.official_uid
  end

  def share(content, photo_url = nil)
    client.update preprocess_content(content)
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def friend_ids(uid, bilateral = false, count)
    []
  end

  def self.parse_image(auth)
    (auth[:profile_image_url] || auth[:info][:image]).to_s.sub('_normal', '')
  end

  private
  def preprocess_content(content)
    content.gsub('@KnewOne', '@KnewOneCom')
  end
end
