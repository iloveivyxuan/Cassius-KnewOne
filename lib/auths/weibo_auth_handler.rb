class WeiboAuthHandler
  attr_reader :client

  def initialize(info)
    @client = WeiboOAuth2::Client.new
    client.get_token_from_hash(access_token: info[:access_token], expires_at: info[:expires_at])
  end

  def follow
    begin
      client.friendships.create(uid: Settings.weibo.official_uid,
                                screen_name: Settings.weibo.official_screen_name)
    rescue OAuth2::Error
    end
  end

  def share(content, photo_url = nil)
    if photo_url
      client.statuses.upload_url_text "status" => preprocess_content(content), "url" => photo_url
    else
      client.statuses.update preprocess_content(content)
    end
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def parse_image(auth)
    auth[:extra][:raw_info][:avatar_large] + ".jpg"
  end

  private
  def preprocess_content(content)
    content
  end
end
