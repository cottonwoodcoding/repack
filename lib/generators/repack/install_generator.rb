module Repack
  # :nodoc:
  class InstallGenerator < ::Rails::Generators::Base
    include GeneratorUtils
    @yarn_installed = false
    source_root File.expand_path("../../../../example", __FILE__)
    desc "Install everything you need for a basic Repack integration"

    copy_webpack_conf

    def create_webpack_application_js
      empty_directory "client"
      empty_directory "client/containers"
      empty_directory "client/components"
      empty_directory "client/__tests__"
      empty_directory "client/__tests__/__mocks__"
      copy_file "babelrc", "./.babelrc"
      copy_file "styleMock.js", "client/__tests__/__mocks__/styleMock.js"
      copy_file "fileMock.js", "client/__tests__/__mocks__/fileMock.js"
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
        unless options[:god]
          copy_file "boilerplate/application.js", "client/application.js"
          copy_file "boilerplate/App.js", "client/containers/App.js"
        end
      end

      haml_installed = Gem.loaded_specs.has_key? 'haml-rails'
      layouts_dir = 'app/views/layouts'
           haml_installed = Gem.loaded_specs.has_key? 'haml-rails'
      layouts_dir = 'app/views/layouts'

      application_view = haml_installed ? "#{layouts_dir}/application.html.haml" : "#{layouts_dir}/application.html.erb"

      if haml_installed
        if yes?('Convert all existing ERB views into HAML? (yes / no)')
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
      if options[:god]
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
          copy_file "boilerplate/god_mode/containers/App.js", "client/containers/App.js"
        end

        copy_file "boilerplate/router_redux/application.js", "client/application.js"
        copy_file "boilerplate/god_mode/routes.js", "client/routes.js"
        copy_file "boilerplate/router_redux/store.js", "client/store.js"
        copy_file "boilerplate/router/NoMatch.js", "client/components/NoMatch.js"
        copy_file "boilerplate/god_mode/actions/auth.js", "client/actions/auth.js"
        copy_file "boilerplate/god_mode/actions/flash.js", "client/actions/flash.js"
        copy_file "boilerplate/god_mode/components/FlashMessage.js", "client/components/FlashMessage.js"
        copy_file "boilerplate/god_mode/components/Login.js", "client/components/Login.js"
        copy_file "boilerplate/god_mode/components/SignUp.js", "client/components/SignUp.js"
        copy_file "boilerplate/god_mode/components/Loading.js", "client/components/Loading.js"
        copy_file "boilerplate/god_mode/reducers/auth.js", "client/reducers/auth.js"
        copy_file "boilerplate/god_mode/reducers/flash.js", "client/reducers/flash.js"
        copy_file "boilerplate/god_mode/reducers/index.js", "client/reducers/index.js"
        copy_file "boilerplate/god_mode/controllers/api/users_controller.rb", "app/controllers/api/users_controller.rb"
        copy_file "boilerplate/god_mode/scss/alert.css.scss", "app/assets/stylesheets/alert.css.scss"

        gem "devise"
        
        token_auth = ask('Use Devise Token Auth - https://github.com/lynndylanhurley/devise_token_auth? (yes \ no)').strip
        if token_auth == 'yes'
          gem 'omniauth'
          gem 'devise_token_auth'
        end

        Bundler.with_clean_env do
          run "bundle update"
        end
        
        run 'bin/spring stop'
        generate "devise:install"
        run "bundle exec rake db:create"
        model_name = ask("What would you like the devise model to be called? [user]")
        model_name = "user" if model_name.blank?

        if token_auth == 'yes'
          mount_point = ask("Auth Mount Point [api/auth]")
          mount_point = "api/auth" if mount_point.blank?
          generate "devise_token_auth:install #{model_name.titleize} #{mount_point}"
        else
          generate "devise", model_name
          generate "devise:controllers #{model_name.pluralize}"
        end
        
        if token_auth == 'no'
          insert_into_file 'config/routes.rb', after: /devise_for :users/ do <<-'RUBY'
  , controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
    namespace :api do
      get 'logged_in_user', to: 'users#logged_in_user'
    end
          RUBY
          end
          ['./app/controllers/users/sessions_controller.rb', './app/controllers/users/registrations_controller.rb'].each do |c|
            insert_into_file c, after: /Devise::\W*.*\n/ do <<-'RUBY'
  skip_before_action :verify_authenticity_token
  respond_to :json
              RUBY
            end
          end
        end
      end
      run 'bundle exec rake db:migrate'
    end

    def whats_next
      if options[:god]
        puts <<-EOF.strip_heredoc
           ██████╗  ██████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗    ███████╗███╗   ██╗ █████╗ ██████╗ ██╗     ███████╗██████╗ 
          ██╔════╝ ██╔═══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝    ██╔════╝████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝██╔══██╗
          ██║  ███╗██║   ██║██║  ██║    ██╔████╔██║██║   ██║██║  ██║█████╗      █████╗  ██╔██╗ ██║███████║██████╔╝██║     █████╗  ██║  ██║
          ██║   ██║██║   ██║██║  ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝      ██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ██║  ██║
          ╚██████╔╝╚██████╔╝██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗    ███████╗██║ ╚████║██║  ██║██████╔╝███████╗███████╗██████╔╝
          ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═════╝                                      

          Note: If you chose a frontend framework (Materialize / Bootstrap) you still need to install the gem and configure it in your project.

        EOF
      end
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
