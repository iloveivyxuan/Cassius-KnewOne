# -*- coding: utf-8 -*-
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

  def share(content, photo_url)
    begin
      if photo_url
        #Open-URI has a 10KB limit on StringIO objects, anything above that and it stores it as a temp file.
        if OpenURI::Buffer.const_defined?('StringMax')
          OpenURI::Buffer.send :remove_const, 'StringMax'
        end
        OpenURI::Buffer.const_set 'StringMax', 0
        tmpfile = open photo_url
        photo = File.open(tmpfile)
        client.statuses.upload content, photo
      else
        client.statuses.update content
      end
    rescue OAuth2::Error
    end
  end

  def topic_wrapper(topic)
    "##{topic}#"
  end

  def parse_image(auth)
    auth[:extra][:raw_info][:avatar_large] + ".jpg"
  end
end
