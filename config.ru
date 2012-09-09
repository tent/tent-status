require 'bundler'
Bundler.require

require './app'

map '/' do
  run StatusPro.new
end
