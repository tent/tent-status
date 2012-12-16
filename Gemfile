source 'https://rubygems.org'
ruby '1.9.3'

gemspec

gem 'tent-client', :git => 'git://github.com/tent/tent-client-ruby.git', :branch => 'master'
gem 'omniauth-tent', :git => 'git://github.com/tent/omniauth-tent.git', :branch => 'master'
gem 'puma'

group :development, :assets do
  gem 'asset_sync', :git => 'git://github.com/titanous/asset_sync.git', :branch => 'fix-mime'
  gem 'mime-types'
  gem 'yui-compressor'
end
