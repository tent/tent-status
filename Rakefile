require 'bundler/setup'
require './config/evergreen'

namespace :spec do
  desc "Run JavaScript specs via Evergreen"
  task :javascripts do
    result = Evergreen::Runner.new.run
    Kernel.exit(1) unless result
  end
end
