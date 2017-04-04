module GeneratorUtils
  def copy_package_json(options)
    copy_file "package.json", "package.json"
    if options[:router] || options[:god]
      insert_into_file './package.json', after: /dependencies\": {\n/ do
        <<-'RUBY'
  "react-router": "^2.4.1",
        RUBY
      end
    end
    if options[:redux] || options[:god]
      insert_into_file './package.json', after: /dependencies\": {\n/ do
        <<-'RUBY'
  "react-redux": "^4.4.5",
  "redux": "^3.5.2",
  "redux-thunk": "^2.1.0",
        RUBY
      end
    end
    if options[:router] && options[:redux] || options[:god]
        insert_into_file './package.json', after: /dependencies\": {\n/ do
        <<-'RUBY'
  "react-router-redux": "^4.0.5",
  "redux-auth-wrapper": "^1.0.0",
        RUBY
        end
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
end