source 'https://rubygems.org'
ruby '1.9.3'

gemspec

gem 'addressable', :require => false
gem 'tent-client', :git => 'git://github.com/tent/tent-client-ruby.git', :branch => 'master', :require => 'tent-client'
gem 'omniauth-tent', :git => 'git://github.com/tent/omniauth-tent.git', :branch => 'master'
gem 'puma'

gem 'marbles-js', :git => 'git://github.com/jvatic/marbles-js.git', :branch => 'master'

group :development, :assets do
  gem 'asset_sync', :git => 'git://github.com/titanous/asset_sync.git', :branch => 'fix-mime'
  gem 'mime-types'
  gem 'yui-compressor'
  gem 'rake'

  gem 'sprockets-helpers', '~> 0.2'
  gem 'sprockets-sass',    '~> 0.5'
  gem 'compass', '~> 0.12.2'
end
