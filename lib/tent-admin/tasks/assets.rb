require 'tent-admin/compiler'

def configure_tent_admin
  return if @tent_admin_configured
  @tent_admin_configured = true
  TentAdmin.configure
end

namespace :icing do
  task :configure do
    configure_tent_admin
    TentAdmin::Compiler.compile_icing = true
  end
end

namespace :marbles do
  task :configure do
    configure_tent_admin
    TentAdmin::Compiler.compile_marbles = true
  end
end

namespace :assets do
  task :configure do
    configure_tent_admin
  end

  task :compile do
    TentAdmin::Compiler.compile_assets
  end

  task :gzip do
    TentAdmin::Compiler.gzip_assets
  end

  task :deploy => :gzip do
    if ENV['S3_ASSETS'] == 'true' && ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'asset_sync'))
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => ['icing:configure', 'marbles:configure', 'deploy']
end
