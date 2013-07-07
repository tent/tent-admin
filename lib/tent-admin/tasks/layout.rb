require 'tent-admin/compiler'

namespace :layout do
  task :compile do
    TentAdmin::Compiler.compile_layout
  end

  task :gzip => :compile do
    output_dir = TentAdmin::Compiler.layout_dir

    Dir["#{output_dir}/index.html"].each do |f|
      path = "#{f}.gz"
      sh "rm #{path}" if File.exists?(path)
      sh "gzip -c #{f} > #{path}"
    end
  end
end
