require 'evergreen'
require 'capybara/poltergeist'

Evergreen.configure do |config|
  config.driver = :poltergeist
  config.public_dir = 'assets'
  config.template_dir = 'spec/javascripts/templates'
  config.spec_dir = 'spec'
end

Evergreen.root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

%w{ javascripts stylesheets images }.each do |path|
  Evergreen.assets.append_path(File.join(Evergreen.root, Evergreen.public_dir, path))
end
