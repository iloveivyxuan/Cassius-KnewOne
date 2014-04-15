#!/usr/bin/env ruby

require 'pry'
require 'oauth2'

CONSOLE = Pry

APP_ID = '9c414322e74aa71057e3523fe4af986dd87256157c730d86c0c08864bb98cf9b'
SECRET = '5456e36028ddde788caba33cedfbf79ff77f5eb0a40135119765be2c119ccfae'
URL = 'http://making.dev'
USERNAME = 'jasl@knewone.com'
PASSWORD = 'aaaaaa'
SCOPES = 'public official haven'

client = OAuth2::Client.new(APP_ID, SECRET, site: URL)
@token = client.password.get_token(USERNAME, PASSWORD, scope: SCOPES)
def token
  @token
end

%i(get post patch put delete).each do |m|
  define_method m do |*args|
    args[0] = "api/v1/#{args[0]}"
    @token.send m, *args
  end
end

puts 'KnewOne interactive API testing tool'
puts '======================================='
puts "Access token: '#{token.token}'."
puts "Call 'token' to test APIs, see Oauth2 gem documents for help."

CONSOLE.start
