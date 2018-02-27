#!/usr/bin/ruby

require 'redis'

puts 'Starting import'

redis = Redis.new
array = []

text = File.open('pt.dic').read
text.each_line do |line|
	array << line.strip
end

data = array.group_by {|s| s[0,1] }.to_hash

data.each { |key, value|
	redis.set key, value
}

puts 'Import completed...'
