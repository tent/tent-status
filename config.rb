require 'static-sprockets'
require 'marbles-js'
require 'marbles-tent-client-js'
require 'icing'
require 'react-jsx-sprockets'
require 'yajl'

StaticSprockets.sprockets_config do |environment|
  MarblesJS::Sprockets.setup(environment)
  MarblesTentClientJS::Sprockets.setup(environment)
  Icing::Sprockets.setup(environment)
end

StaticSprockets.configure(
  :asset_roots => [
    File.expand_path(File.join(File.dirname(__FILE__), 'src')),
    File.expand_path(File.join(File.dirname(__FILE__), 'vendor'))
  ],
  :asset_types => %w( javascripts stylesheets images ),
  :layout => File.expand_path(File.join(File.dirname(__FILE__), 'src', 'layout.html.erb')),
  :layout_output_name => 'micro.html',
  :output_dir => ENV['OUTPUT_DIR'] || File.expand_path(File.join(File.dirname(__FILE__), 'build')),
  :asset_root => ENV['ASSET_ROOT'] || "/assets"
)
