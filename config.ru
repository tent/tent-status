lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler'
Bundler.require

$stdout.sync = true

require 'tent-status/app'

map '/' do
  use Rack::Session::Cookie,  :key => 'tent-status.session',
                              :expire_after => 2592000, # 1 month
                              :secret => ENV['COOKIE_SECRET'] || SecureRandom.hex
  run Tent::Status.new
end
