module Repack
  # :nodoc:
  class GodInstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)
    desc "Install everything you need for a basic repack integration with react router / redux / devise / token auth"

    def check_god_mode
      unless yes?('Is this a new application? (yes \ no)')
        raise 'GOD MODE is for new apps only. Run again at your own risk!'
      end
    end

    def copy_package_json
      copy_file "package.json", "package.json"
      insert_into_file './package.json', after: /dependencies\": {\n/ do
        <<-'RUBY'
  "react-router": "^2.4.1",
  "react-redux": "^4.4.5",
  "redux": "^3.5.2",
  "redux-thunk": "^2.1.0",
  "react-router-redux": "^4.0.5",
  "redux-auth-wrapper": "^1.0.0",
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

    def self.frontend_config(frontend_gem, sheet_imports, sheet_name = 'application.css', new_sheet_name = 'application.scss')
      begin
        gem frontend_gem
        File.rename "app/assets/stylesheets/#{sheet_name}", "app/assets/stylesheets/#{new_sheet_name}"
        File.open("app/assets/stylesheets/#{new_sheet_name}", 'w+') do |f|
          sheet_imports.each do |import|
            f.write("@import #{import}; \n")
          end
        end
      rescue => e
        puts "Error While Setting Up Frontend Framework: #{e}"
      end
    end

    def finishing_god_move
      base_sheet_path = "app/assets/stylesheets"
      nav_template = ask('Frontend Framework: 1) Materialize, 2) Bootstrap, 3) None').strip
      case nav_template
        when '1'
          sheet_imports = [ 'materialize', 'alert' ]
          gem 'materialize-sass'
          if File.exists? "#{base_sheet_path}/application.css"
            File.rename "#{base_sheet_path}/application.css", "#{base_sheet_path}/application.scss"
          end
          File.open("#{base_sheet_path}/application.scss", 'w+') do |f|
            sheet_imports.each do |import|
              f.write("@import '#{import}'; \n")
            end
          end
          copy_file "boilerplate/god_mode/components/MaterialNavbar.js", "client/components/Navbar.js"
        when '2'
          sheet_imports = [ 'bootstrap-sprockets', 'bootstrap', 'alert' ]
          gem 'bootstrap-sass'
          if File.exists? "#{base_sheet_path}/application.css"
            File.rename "#{base_sheet_path}/application.css", "#{base_sheet_path}/application.scss"
          end
          File.open("#{base_sheet_path}/application.scss", 'w+') do |f|
            sheet_imports.each do |import|
              f.write("@import '#{import}'; \n")
            end
          end
          copy_file "boilerplate/god_mode/components/BootstrapNavbar.js", "client/components/Navbar.js"
        when '3'
          puts 'No Navbar template, all the components are ready for you to implement however you want.'
        else
          puts 'Wrong template choice, try again!'
          finishing_god_move
      end

      if nav_template == '3'
        copy_file "boilerplate/god_mode/containers/NoNavApp.js", "client/containers/App.js"
      else
        copy_file "boilerplate/god_mode/containers/TokenApp.js", "client/containers/App.js"
      end

      copy_file "boilerplate/router_redux/application.js", "client/application.js"
      copy_file "boilerplate/god_mode/tokenRoutes.js", "client/routes.js"
      copy_file "boilerplate/router_redux/store.js", "client/store.js"
      copy_file "boilerplate/router/NoMatch.js", "client/components/NoMatch.js"
      copy_file "boilerplate/god_mode/actions/tokenAuth.js", "client/actions/auth.js"
      copy_file "boilerplate/god_mode/actions/flash.js", "client/actions/flash.js"
      copy_file "boilerplate/god_mode/components/FlashMessage.js", "client/components/FlashMessage.js"
      copy_file "boilerplate/god_mode/components/Login.js", "client/components/Login.js"
      copy_file "boilerplate/god_mode/components/SignUp.js", "client/components/SignUp.js"
      copy_file "boilerplate/god_mode/components/Loading.js", "client/components/Loading.js"
      copy_file "boilerplate/god_mode/reducers/auth.js", "client/reducers/auth.js"
      copy_file "boilerplate/god_mode/reducers/flash.js", "client/reducers/flash.js"
      copy_file "boilerplate/god_mode/reducers/index.js", "client/reducers/index.js"
      copy_file "boilerplate/god_mode/scss/alert.css.scss", "app/assets/stylesheets/alert.css.scss"

      gem "devise"
      gem 'omniauth'
      gem 'devise_token_auth'
      insert_into_file './package.json', after: /dependencies\": {\n/ do
      <<-'RUBY'
  "j-toker": "^0.0.10-beta3",
      RUBY
    end

      insert_into_file './app/controllers/application_controller.rb', after: /ActionController::Base\n/ do
      <<-'RUBY'
  skip_before_action :verify_authenticity_token
      RUBY
    end
    
      Bundler.with_clean_env do
        run "bundle update"
      end
      
      run 'bin/spring stop'
      generate "devise:install"
      run "bundle exec rake db:create"
      model_name = ask("What would you like the devise model to be called? [user]")
      model_name = "user" if model_name.blank?

      mount_point = ask("Auth Mount Point [api/auth]")
      mount_point = "api/auth" if mount_point.blank?
      generate "devise_token_auth:install #{model_name.titleize} #{mount_point}"

      run 'bundle exec rake db:migrate'
    end

    def whats_next
      puts <<-EOF.strip_heredoc
          ██████╗  ██████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗    ███████╗███╗   ██╗ █████╗ ██████╗ ██╗     ███████╗██████╗ 
        ██╔════╝ ██╔═══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝    ██╔════╝████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗
        ██║  ███╗██║   ██║██║  ██║    ██╔████╔██║██║   ██║██║  ██║█████╗      █████╗  ██╔██╗ ██║███████║██████╔╝██║     █████╗  ██║  ██║
        ██║   ██║██║   ██║██║  ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝      ██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ██║  ██║
        ╚██████╔╝╚██████╔╝██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗    ███████╗██║ ╚████║██║  ██║██████╔╝███████╗███████╗██████╔╝
        ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═════╝                                      

        Note: If you chose a frontend framework (Materialize / Bootstrap) you still need to install the gem and configure it in your project.

      EOF
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
