module Repack
  # :nodoc:
  class RouterInstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)
    desc "Install everything you need for a basic repack integration with react router"

    def copy_package_json
      copy_file "package.json", "package.json"

      insert_into_file './package.json', after: /dependencies\": {\n/ do
        <<-'RUBY'
  "react-router": "^2.4.1",
        RUBY
      end
    end

    def copy_webpack_conf
      copy_file "webpack.config.js", "config/webpack.config.js"
      if yes?('Are you going to be deploying to heroku? (yes \ no)')
        puts 'Copying Heroku Webpack Config!'
        copy_file "webpack.config.heroku.js", "config/webpack.config.heroku.js"
        puts 'Adding Basic Puma Proc File'
        copy_file "Procfile", 'Procfile'
      end
    end

    def create_webpack_application_js
      empty_directory "client"
      empty_directory "client/containers"
      empty_directory "client/components"
      empty_directory "client/__tests__"
      empty_directory "client/__tests__/__mocks__"
      copy_file "babelrc", "./.babelrc"
      copy_file "styleMock.js", "client/__tests__/__mocks__/styleMock.js"
      copy_file "fileMock.js", "client/__tests__/__mocks__/fileMock.js"
      copy_file "boilerplate/router/application.js", "client/application.js"
      copy_file "boilerplate/routes.js", "client/routes.js"
      copy_file "boilerplate/router/App.js", "client/containers/App.js"
      copy_file "boilerplate/router/NoMatch.js", "client/components/NoMatch.js"
    end

    def layouts
      layouts_dir = 'app/views/layouts'

      application_view = "#{layouts_dir}/application.html.erb"

      insert_into_file application_view, before: /<\/head>/ do <<-'RUBY'
  <% if Rails.env.development? %>
    <script src="http://localhost:3808/webpack-dev-server.js"></script>
  <% end %>
      RUBY
      end
      insert_into_file application_view, before: /<\/body>/ do <<-'RUBY'
  <%= javascript_include_tag *webpack_asset_paths('application') %>
      RUBY
      end
    end
    
    def add_to_gitignore
      append_to_file ".gitignore" do
        <<-EOF.strip_heredoc
        /node_modules
        /public/webpack
        npm-debug.log
        EOF
      end
    end

    def whats_next
      puts <<-EOF.strip_heredoc
        We've set up the basics of repack for you, but you'll still
        need to:
          1. yarn install or npm install
          2. Add an element with an id of 'app' to your layout
          3. To disable hot module replacement remove <script src="http://localhost:3808/webpack-dev-server.js"></script> from layout
          4. Run 'yarn / npm dev_server' to run the webpack-dev-server
          5. Run 'bundle exec rails s' to run the rails server (both servers must be running)
          6. If you are using react-router or god mode and want to sync server routes add:
            get '*unmatched_route', to: <your client controller>#<default action>
            This must be the very last route in your routes.rb file
            e.g. get '*unmatched_route', to: 'home#index'
          FOR HEROKU DEPLOYS:
          1.  yarn / npm heroku-setup
          2.  Push to heroku the post-build hook will take care of the rest
        See the README.md for this gem at
        https://github.com/cottonwoodcoding/repack/blob/master/README.md
        for more info.
          
        Thanks for using Repack!
      EOF
    end
  end
end
