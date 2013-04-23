require 'bundler/setup'
require 'bundler/gem_tasks'

namespace :assets do
  Rake::SprocketsTask.new do |t|
    # Get rid of old compiled assets
    %x{rm -rf ./public}

    # Setup Sprockets Environment
    require 'rack-putty'
    require 'tent-admin/app/middleware'
    require 'tent-admin/app/asset_server'
    t.environment = TentAdmin::AssetServer.sprockets_environment(
      :asset_root => 'lib/assets',
      :logfile => '/dev/null'
    )

    t.environment.js_compressor = Uglifier.new
    t.environment.css_compressor = YUI::CssCompressor.new

    t.output      = "./public/assets"
    t.assets      = []
    t.manifest = proc { Sprockets::Manifest.new(t.environment, "./public/assets", "./public/assets/manifest.json") }
  end

  task :gzip_assets => :assets do
    Dir['public/assets/**/*.*'].reject { |f| f =~ /\.gz\z/ }.each do |f|
      sh "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
    end
  end

  task :deploy_assets => :gzip_assets do
    if ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require './config/asset_sync'
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => :deploy_assets
end
