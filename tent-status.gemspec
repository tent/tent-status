# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tent-status/version'

Gem::Specification.new do |gem|
  gem.name          = "tent-status"
  gem.version       = TentStatus::VERSION
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jesse@jessestuart.ca"]
  gem.description   = %(Tent app for 256 character posts. See README for details.)
  gem.summary       = %(Tent app for 256 character posts)
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_runtime_dependency 'rack-putty'
  gem.add_runtime_dependency 'tent-client'
  gem.add_runtime_dependency 'omniauth-tent'

  gem.add_runtime_dependency 'mimetype-fu'
  gem.add_runtime_dependency 'sprockets'      , '~> 2.0'
  gem.add_runtime_dependency 'sprockets-sass' , '~> 0.5'
  gem.add_runtime_dependency 'coffee-script'
  gem.add_runtime_dependency 'marbles-js'
  gem.add_runtime_dependency 'lodash-assets'
  gem.add_runtime_dependency 'hogan_assets'
  gem.add_runtime_dependency 'icing'

  gem.add_runtime_dependency 'pg'
  gem.add_runtime_dependency 'sequel', '3.46'
  gem.add_runtime_dependency 'sequel-json'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'asset_sync'
  gem.add_development_dependency 'mime-types'
  gem.add_development_dependency 'uglifier'
  gem.add_development_dependency 'yui-compressor'
end
