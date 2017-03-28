module Repack
  # :nodoc:
  class ViewGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)

    desc "Generate a view with webpack entry / rails view / and react container"

    def normalize_view_name
      raise "View name argument missing" if args.length == 0
      @view = args[0]
    end

    # ASSUMPTION: entry file will be snake_cased
    def update_webpack_entry
      name = @view.underscore
      path = "'#{name}': './client/#{name}.js',"
      insert_into_file 'config/webpack.config.js', after: /entry: {\n/ do
        <<-CONFIG
    #{path}
        CONFIG
      end
    end

    def create_entry_file
      file = "client/#{@view.underscore}.js"
      name = @view.titleize.gsub(/ /, '')
      copy_file "boilerplate/views/ViewTemplate.js", file
      gsub_file file, /Placeholder/, name
    end

    # ASSUMPTION: container will be PascalCased
    def create_container
      name = @view.titleize.gsub(/ /, '')
      file = "client/containers/#{name}.js"
      copy_file "boilerplate/views/ContainerTemplate.js", file
      gsub_file file, /Placeholder/, name
    end

    # ASSUMPTION: Rails controllers will be PascalCased, file & directory names will be snake_cased
    def create_rails_view
      name = @view.underscore
      Rails.application.eager_load! if ApplicationController.descendants.length == 0
      controllers = ApplicationController.descendants.map { |cont| cont.name.gsub('Controller', '').underscore }
      dirname = controllers.include?(name) ? name : name.pluralize
      empty_directory "app/views/#{dirname}"
      if Gem.loaded_specs.has_key? 'haml-rails'
        file = "app/views/#{dirname}/index.html.haml"
        copy_file "boilerplate/views/rails_view.html.haml", file
        gsub_file file, /placeholder/, name
      else
        file = "app/views/#{dirname}/index.html.erb"
        copy_file "boilerplate/views/rails_view.html.erb", file
        gsub_file file, /placeholder/, name
      end
    end
  end
end
