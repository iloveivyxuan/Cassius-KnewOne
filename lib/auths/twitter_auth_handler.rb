# -*- coding: utf-8 -*-
class TwitterAuthHandler
  attr_reader :client

  def initialize(info)
    @client = Twitter::Client.new access_token: info[:access_token],
    access_token_secret: info[:access_secret],
    consumer_key: Settings.twitter.consumer_key,
    consumer_secret: Settings.twitter.consumer_secret
  end

  def follow
    client.follow Settings.twitter.official_uid
  end

  def share(content, photo_url)
    client.update content
  end

  def topic_wrapper(topic)
    "@#{topic} "
  end

  def parse_image(auth)
    auth[:info][:image].sub('_normal', '')
  end
end
