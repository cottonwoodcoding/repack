module Repack
  # :nodoc:
  class GodInstallGenerator < ::Rails::Generators::Base
    @yarn_installed = false
    source_root File.expand_path("../../../../example", __FILE__)
    desc "Install everything you need for Repack God Mode"

    def check_god_mode
      unless yes?('Is this a new application? (yes \ no)')
        raise 'GOD MODE is for new apps only. Run again at your own risk!'
      end
    end
  end
end