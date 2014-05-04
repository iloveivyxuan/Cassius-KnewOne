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

  query = params.sort.push(['timestamp', timestamp]).map do |key, value|
    "#{key}=#{value}"
  end.join('&')

  sign = Digest::MD5.hexdigest("#{query}#{SECRET}")

  puts "Query: #{query}&sign=#{sign}"

  sign
end

def request(path, m = :get, opts = {})
  url = BASE_URL + path + '.json'

  opts.merge! timestamp: Time.now.to_i unless opts[:timestamp]

  RestClient.send(m, url, params: opts.merge(sign: generate(stringify_keys(opts))))
end

%w(get post patch put delete).each do |m|
  instance_eval <<-EVAL
    def #{m}(path, opts={})
      JSON.parse request(path, :#{m}, opts)
    end
  EVAL
end

puts 'KnewOne interactive Hell API testing tool'
puts '======================================='

CONSOLE.start
