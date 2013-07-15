require 'tent-status/compiler'

namespace :layout do
  task :compile do
    TentStatus::Compiler.compile_layout
  end

  task :gzip do
    TentStatus::Compiler.gzip_layout
  end
end
