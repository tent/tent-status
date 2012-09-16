lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler'
Bundler.require

require 'tent-statusapp/app'

map '/' do
  run Tent::StatusApp.new
end
