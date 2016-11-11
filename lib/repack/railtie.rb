require 'rails'
require 'rails/railtie'
require 'repack/helper'

module Repack
  # :nodoc:
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      ActiveSupport.on_load(:action_view) do
        include Repack::Helper
      end
    end

    config.repack = ActiveSupport::OrderedOptions.new
    config.repack.config_file = 'config/webpack.config.js'
    config.repack.binary = 'node_modules/.bin/webpack'

    config.repack.dev_server = ActiveSupport::OrderedOptions.new
    config.repack.dev_server.host = 'localhost'
    config.repack.dev_server.port = 3808
    config.repack.dev_server.https = false # note - this will use OpenSSL::SSL::VERIFY_NONE
    config.repack.dev_server.binary = 'node_modules/.bin/webpack-dev-server'
    config.repack.dev_server.enabled = !::Rails.env.production?

    config.repack.output_dir = "public/client"
    config.repack.public_path = "client"
    config.repack.manifest_filename = "manifest.json"

    rake_tasks do
      load "tasks/repack.rake"
    end
  end
end
