# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "tent-status"
  gem.version       = '0.0.1'
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jessestuart@gmail.com"]
  gem.description   = %q{Tent app for 140 character posts. Uses Sinatra/Sprockets + CoffeeScript}
  gem.summary       = %q{Tent app for 140 character posts}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'tent-client'
  gem.add_runtime_dependency 'sinatra'
  gem.add_runtime_dependency 'rack_csrf'
  gem.add_runtime_dependency 'sequel'
  gem.add_runtime_dependency 'pg'
  gem.add_runtime_dependency 'sprockets', '~> 2.0'
  gem.add_runtime_dependency 'tilt'
  gem.add_runtime_dependency 'sass'
  gem.add_runtime_dependency 'coffee-script'
  gem.add_runtime_dependency 'slim'
  gem.add_runtime_dependency 'uglifier'
  gem.add_runtime_dependency 'hogan_assets'
  gem.add_runtime_dependency 'asset_sync', '~> 0.5.0'
  gem.add_runtime_dependency 'hashie'

  gem.add_development_dependency 'kicker'
end
