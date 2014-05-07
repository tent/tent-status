require 'bundler'
Bundler.require

$stdout.sync = true

require './config'

require 'static-sprockets/app'
map '/' do
  run StaticSprockets::App.new
end
