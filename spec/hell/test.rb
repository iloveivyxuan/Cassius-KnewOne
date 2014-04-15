#!/usr/bin/env ruby

require 'pry'
require 'rest_client'
require 'json'

CONSOLE = Pry

BASE_URL = 'http://making.dev/hell/'
SECRET = 'd15cd239'

def stringify_keys(hash)
  new_hash = {}
  hash.each do |key, value|
    new_hash[(key.to_s rescue key) || key] = value
  end
  new_hash
end

def generate(params)
  timestamp = params.delete 'timestamp'

  query = params.sort.map do |key, value|
    "#{key}=#{value}"
  end.join('&')

  puts "Query: #{query}"

  if query.size == 0
    Digest::MD5.hexdigest("timestamp=#{timestamp}#{SECRET}")
  else
    Digest::MD5.hexdigest("#{query}&timestamp=#{timestamp}#{SECRET}")
  end
end

# %i(get post patch put delete).each do |m|
#   instance_eval <<-EVAL
#     def #{m}(path, opts={})
#       url = BASE_URL + path + '.json'
#       opts.merge! :timestamp, Time.now.to_i
#       opts.merge! sign: generate(opts)
#
#       puts "[\#{m.to_s.upcase}] \#{url} Params: \#{opts}"
#       RestClient.send url, params: opts
#     end
#   EVAL
# end

def get(path, opts = {})
  url = BASE_URL + path + '.json'

  opts.merge! timestamp: Time.now.to_i

  JSON.parse RestClient.send(:get, url, params: opts.merge(sign: generate(stringify_keys(opts))))
end

puts 'KnewOne interactive Hell API testing tool'
puts '======================================='

CONSOLE.start
