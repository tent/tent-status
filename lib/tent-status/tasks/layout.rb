require 'tent-status/compiler'

namespace :layout do
  task :compile do
    TentStatus::Compiler.compile_layout
  end

  task :gzip => :compile do
    output_dir = TentStatus::Compiler.layout_dir

    Dir["#{output_dir}/index.html"].each do |f|
      path = "#{f}.gz"
      sh "rm #{path}" if File.exists?(path)
      sh "gzip -c #{f} > #{path}"
    end
  end
end
