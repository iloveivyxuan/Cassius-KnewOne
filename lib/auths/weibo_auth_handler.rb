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
    begin
      if photo_url.present?
        client.statuses.upload_url_text "status" => preprocess_content(content), "url" => photo_url
      else
        client.statuses.update preprocess_content(content)
      end
    rescue OAuth2::Error => ex
      # retry again
      client.statuses.update preprocess_content(content)
      # raise ex
    end
  end

  def friend_ids(uid, bilateral = false, count = 500)
    begin
      if bilateral
        client.friendships.friends_bilateral_ids(uid: uid, count: count).ids
      else
        client.friendships.friends_ids(uid: uid, count: count).ids
      end
    rescue OAuth2::Error
      []
    end
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def self.parse_image(auth)
    (auth[:avatar_large] || auth[:extra][:raw_info][:avatar_large]) + ".jpg"
  end

  private
  def preprocess_content(content)
    content
  end
end
