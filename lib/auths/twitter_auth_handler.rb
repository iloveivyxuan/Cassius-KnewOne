class TwitterAuthHandler
  attr_reader :client

  def initialize(info)
    @client = Twitter::REST::Client.new access_token: info[:access_token],
    access_token_secret: info[:access_secret],
    consumer_key: Settings.twitter.consumer_key,
    consumer_secret: Settings.twitter.consumer_secret
  end

  def follow
    client.follow Settings.twitter.official_uid
  end

  def share(content, photo_url)
    client.update preprocess_content(content)
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def parse_image(auth)
    auth[:info][:image].sub('_normal', '')
  end

  private
  def preprocess_content(content)
    content.gsub('@KnewOne', '@knewonecom')
  end
end
