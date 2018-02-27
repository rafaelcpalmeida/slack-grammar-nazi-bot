#!/usr/bin/ruby

require 'redis'

puts 'Starting import'

redis = Redis.new

text = File.open('pt.dic').read
text.each_line do |line|
	redis.set(line.strip, line.strip)
end

puts 'Import completed...'