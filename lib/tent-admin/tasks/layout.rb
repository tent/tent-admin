require 'tent-admin/compiler'

namespace :layout do
  task :compile do
    TentAdmin::Compiler.compile_layout
  end

  task :gzip do
    TentAdmin::Compiler.gzip_layout
  end
end
