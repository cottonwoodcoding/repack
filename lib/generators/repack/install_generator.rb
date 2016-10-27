module Repack
  # :nodoc:
  class InstallGenerator < ::Rails::Generators::Base
    @yarn_installed = false
    source_root File.expand_path("../../../../example", __FILE__)
    desc "Install everything you need for a basic repack integration"
    class_option :router, type: :boolean, default: false, description: 'Add React Router'
    class_option :redux, type: :boolean, default: false, description: 'Add Redux'
    def copy_package_json
      copy_file "package.json", "package.json"
      if options[:router]
        insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-router": "^2.4.1",
          RUBY
        end
      end
      if options[:redux]
        insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-redux": "^4.4.5",
    "redux": "^3.5.2",
    "redux-thunk": "^2.1.0",
          RUBY
        end
      end
      if options[:router] && options[:redux]
          insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-router-redux": "^4.0.5",
          RUBY
         end
      end
    end
    def copy_webpack_conf
      copy_file "webpack.config.js", "config/webpack.config.js"
      puts 'Are you going to be deploying to heroku? (yes \ no)'
      if gets.strip.downcase =~ /y(es)?/
        puts 'copying heroku webpack config!'
        copy_file "webpack.config.heroku.js", "config/webpack.config.heroku.js"
      end
    end
    def create_webpack_application_js
      empty_directory "client"
      empty_directory "client/containers"
      empty_directory "client/components"
      if options[:router] && options[:redux]
        copy_file "boilerplate/router_redux/application.js", "client/application.js"
        copy_file "boilerplate/routes.js", "client/routes.js"
        copy_file "boilerplate/router_redux/store.js", "client/store.js"
        copy_file "boilerplate/router_redux/reducers.js", "client/reducers/index.js"
        create_file "client/actions.js"
        copy_file "boilerplate/router/App.js", "client/containers/App.js"
        copy_file "boilerplate/router/NoMatch.js", "client/components/NoMatch.js"
      elsif options[:router]
        copy_file "boilerplate/router/application.js", "client/application.js"
        copy_file "boilerplate/routes.js", "client/routes.js"
        copy_file "boilerplate/router/App.js", "client/containers/App.js"
        copy_file "boilerplate/router/NoMatch.js", "client/components/NoMatch.js"
      elsif options[:redux]
        copy_file "boilerplate/redux/application.js", "client/application.js"
        copy_file "boilerplate/redux/store.js", "client/store.js"
        copy_file "boilerplate/redux/reducers.js", "client/reducers/index.js"
        create_file "client/actions.js"
        copy_file "boilerplate/App.js", "client/containers/App.js"
      else
        copy_file "boilerplate/application.js", "client/application.js"
        copy_file "boilerplate/App.js", "client/containers/App.js"
      end

      haml_installed = Gem.loaded_specs.has_key? 'haml-rails'
      layouts_dir = 'app/views/layouts'
           haml_installed = Gem.loaded_specs.has_key? 'haml-rails'
      layouts_dir = 'app/views/layouts'

      application_view = haml_installed ? "#{layouts_dir}/application.html.haml" : "#{layouts_dir}/application.html.erb"

      if haml_installed
        puts 'Convert all existing ERB views into HAML? (yes / no)'
        if gets.strip.downcase =~ /y(es)?/
          begin
            require 'html2haml'
          rescue LoadError
            `gem install html2haml`
          end
          `find . -name \*.erb -print | sed 'p;s/.erb$/.haml/' | xargs -n2 html2haml`
          `rm #{layouts_dir}/application.html.erb`
        end

        insert_into_file application_view, before: /%body/ do
          <<-'RUBY'
    - if Rails.env.development?
      %script{:src => "http://localhost:3808/webpack-dev-server.js"}
          RUBY
        end

        insert_into_file application_view, after: /= yield/ do
            <<-'RUBY'

    = javascript_include_tag *webpack_asset_paths('application')
            RUBY
        end
      else
        insert_into_file application_view, before: /<\/head>/ do
          <<-'RUBY'
<% if Rails.env.development? %>
  <script src="http://localhost:3808/webpack-dev-server.js"></script>
<% end %>
          RUBY
        end
        insert_into_file application_view, before: /<\/body>/ do
          <<-'RUBY'
<%= javascript_include_tag *webpack_asset_paths('application') %>
          RUBY
        end
      end
    end
    def add_to_gitignore
      append_to_file ".gitignore" do
        <<-EOF.strip_heredoc
        /node_modules
        /public/webpack
        EOF
      end
    end

    def install_yarn
      puts 'Do you want to install and use yarn as your package manager? (yes / no)'
      if gets.strip.downcase =~ /y(es)?/
        @yarn_installed = true
        run "npm install yarn --save-dev"
      end
    end

    def run_package_manager_install
      if @yarn_installed
        run "yarn install" if yes?("Would you like us to run 'yarn install' for you?")
      else
        run "npm install" if yes?("Would you like us to run 'npm install' for you?")
      end
    end

    def whats_next
      puts <<-EOF.strip_heredoc
        We've set up the basics of repack for you, but you'll still
        need to:
          1. Add an element with an id of 'app' to your layout
          2. To disable hot module replacement remove <script src="http://localhost:3808/webpack-dev-server.js"></script> from layout
          3. Run 'yarn run dev_server' to run the webpack-dev-server
          4. Run 'bundle exec rails s' to run the rails server (both servers must be running)
          5. If you are using react-router and want to sync server routes add:
             get '*unmatched_route', to: <your client controller>#<default action>
             This must be the very last route in your routes.rb file
             e.g. get '*unmatched_route', to: 'home#index'
          FOR HEROKU DEPLOYS:
          1.  yarn run heroku-setup
          2.  Push to heroku the post-build hook will take care of the rest
        See the README.md for this gem at
        https://github.com/cottonwoodcoding/repack/blob/master/README.md
        for more info.
        Thanks for using repack!
      EOF
    end
  end
end
