#!/usr/bin/env ruby

require 'pry'
require 'oauth2'
require 'active_support/core_ext'
require 'rest_client'

CONSOLE = Pry

APP_ID = '9c414322e74aa71057e3523fe4af986dd87256157c730d86c0c08864bb98cf9b'
APP_SECRET = '5456e36028ddde788caba33cedfbf79ff77f5eb0a40135119765be2c119ccfae'
URL = ARGV[2] || 'http://making.dev'
USERNAME = ARGV[0] || 'jasl@knewone.com'
PASSWORD = ARGV[1] || 'aaaaaa'
SCOPES = 'public official'
SECRET = ''

def generate_sign(params = {}, secret = SECRET)
  timestamp = params.delete 'timestamp'

  query = params.sort.push(['timestamp', timestamp]).map do |key, value|
    "#{key}=#{value}"
  end.join('&')

  Digest::MD5.hexdigest("#{query}#{secret}")
end

def signed_params(params = {}, secret = SECRET)
  params = params.stringify_keys
  params['timestamp'] ||= Time.now.to_i.to_s
  params['sign'] ||= generate_sign params.dup, secret
  params
end

client = OAuth2::Client.new(APP_ID, APP_SECRET, site: URL)
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
