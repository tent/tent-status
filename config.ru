require 'bundler'
Bundler.require

require './app'

map '/' do
  run StatusApp.new
end
