#!/usr/bin/env ruby

require 'pry'
require 'oauth2'

CONSOLE = Pry

APP_ID = '98aada7a9e5d027dc8f9077e9ffed1f3842b1c71072cf88c5232531b1688801c'
SECRET = 'a972e416053f74f21b41d8960eb1a595a6c79fd84d6731744c09b634fb376cf3'
URL = 'http://making.dev'
USERNAME = 'jasl@knewone.com'
PASSWORD = 'aaaaaa'

client = OAuth2::Client.new(APP_ID, SECRET, site: URL)
@token = client.password.get_token(USERNAME, PASSWORD)
def token
  @token
end

%i(get post patch put delete).each do |m|
  define_method m do |*args|
    @token.send m, *args
  end
end

puts 'KnewOne interactive API testing tool'
puts '======================================='
puts "Access token: '#{token.token}'."
puts "Call 'token' to test APIs, see Oauth2 gem documents for help."

CONSOLE.start
