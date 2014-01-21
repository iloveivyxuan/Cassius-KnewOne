#!/usr/bin/env ruby

require 'pry'
require 'oauth2'

CONSOLE = Pry

APP_ID = '0719b4c46134ef3cdb5033b2e3e15d81d5a10c5e2dc6c8dd6bcb9c5c9b1dd5be'
SECRET = '0569fb770c1ec2c0488420f8278e76c765e300ea8d3c487ea06947e4c79a9bcf'
URL = 'http://making.dev'
USERNAME = 'jasl@knewone.com'
PASSWORD = 'aaaaaa'

client = OAuth2::Client.new(APP_ID, SECRET, site: URL)
@token = client.password.get_token(USERNAME, PASSWORD)
def token
  @token
end

puts 'KnewOne interactive API testing tool'
puts '======================================='
puts "Access token: '#{token.token}'."
puts "Call 'token' to test APIs, see Oauth2 gem documents for help."

CONSOLE.start
