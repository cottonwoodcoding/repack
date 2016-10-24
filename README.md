# repack

**repack** gives you tools to integrate Webpack and React in to an existing Ruby on Rails application.

It will happily co-exist with sprockets but does not use it for production fingerprinting or asset serving. **repack** is designed with the assumption that if you're using Webpack you treat Javascript as a first-class citizen. This means that you control the webpack config, package.json, and use npm to install Webpack & its plugins.

In development mode [webpack-dev-server](http://webpack.github.io/docs/webpack-dev-server.html) is used to serve webpacked entry points and offer hot module reloading. In production entry points are built in to `public/client`. **repack** uses [stats-webpack-plugin](https://www.npmjs.com/package/stats-webpack-plugin) to translate entry points in to asset paths.

It was forked from the [Marketplacer](http://www.marketplacer.com) repo: (https://github.com/mipearson/webpack-rails) and support for React / Babel / ES6 was added.

This gem has been tested against Rails 4.2 and Ruby 2.2. Earlier versions of Rails (>= 3.2) and Ruby (>= 1.9) may work, but we haven't tested them.

## Using repack

### Install Flags
  1. No Flags -> Basic Webpack and React Boilerplate
  2. --router -> Webpack / React / React Router Boilerplate
  3. --redux -> Webpack / React / Redux Boilerplate
  4. --router --redux -> Webpack / React / Router / Redux Boilerplate

### Installation

  1. Add `repack` to your gemfile
  2. Run `bundle install` to install the gem
  3. Run `bundle exec rails generate repack:install` to copy across example files
  4. Run `npm run dev_server` to start `webpack-dev-server`
  5. Add the webpack entry point to your layout (see next section)
  6. Edit `client/application.js` and write some code

### Adding the entry point to your Rails application

To add your webpacked javascript in to your app, add the following to the `<body>` section of any layout by default it has been added to `layout.html.erb`:

```erb
<%= javascript_include_tag *webpack_asset_paths("application") %>
```

Take note of the splat (`*`): `webpack_asset_paths` returns an array, as one entry point can map to multiple paths, especially if hot reloading is enabled in Webpack.

#### Use with webpack-dev-server live reload

If you're using the webpack dev server's live reload feature (not the React hot reloader), you'll also need to include the following in your layout template:

``` html
<script src="http://localhost:3808/webpack-dev-server.js"></script>
```

This has been added to layouts/index.html.erb by default.

### Configuration Defaults

  * Webpack configuration lives in `config/webpack.config.js`
  * Webpack & Webpack Dev Server binaries are in `node_modules/.bin/`
  * Webpack Dev Server will run on port 3808 on localhost via HTTP
  * Webpack Dev Server is enabled in development & test, but not in production
  * Webpacked assets will be compiled to `public/client`
  * The manifest file is named `manifest.json`

### Working with browser tests

In development, we make sure that the `webpack-dev-server` is running when browser tests are running.

#### Continuous Integration

In CI, we manually run `webpack` to compile the assets to public and set `config.webpack.dev_server.enabled` to `false` in our `config/environments/test.rb`:

``` ruby
  config.webpack.dev_server.enabled = !ENV['CI']
```

### Production Deployment

If deploying to heroku, you will need to set your buildpacks before pushing. After adding the heroku git remote, run the below three commands:

```
  heroku buildpacks:clear
  heroku buildpacks:set heroku/nodejs
  heroku buildpacks:add heroku/ruby --index 2
```

This will set the Node.js buildpack to run first, followed by the Ruby buildpack. To confirm that your buildpacks are set correctly, run `heroku buildpacks`. You should see Node.js listed first and Ruby second.

Next you will need to set up a post build hook to bundle Webpack. Include the below scripts in `package.json`. For the Webpack deployment script, ensure that the route for your `webpack.config.js` file is correct.

``` javascript
  "scripts": {
    "webpack:deploy": "webpack --config=config/webpack.config.js -p",
    "heroku-postbuild": "npm run webpack:deploy"
  }
```

Lastly, ensure that all Babel related modules are listed as dependencies and not dev dependencies in `package.json`. At this point, you should be able to push to Heroku.

An alternative to adding the post build hook to `package.json` is to add `rake webpack:compile` to your deployment. It serves a similar purpose as Sprockets' `assets:precompile` task. If you're using Webpack and Sprockets (as we are at Marketplacer) you'll need to run both tasks - but it doesn't matter which order they're run in.

If you're using `[chunkhash]` in your build asset filenames (which you should be, if you want to cache them in production), you'll need to persist built assets between deployments. Consider in-flight requests at the time of deployment: they'll receive paths based on the old `manifest.json`, not the new one.

## Example Apps
* [basic](https://github.com/cottonwoodcoding/webpack-rails-react-basic)
* [react-router](https://github.com/cottonwoodcoding/webpack-rails-react-router)
* [redux](https://github.com/cottonwoodcoding/webpack-rails-react-redux)
* [redux react-router](https://github.com/cottonwoodcoding/webpack-rails-react-redux-router)

## TODO

* Add eslint to client
* Integration tests
* Port example apps to Repack


## Experimental
A view generator has been added.

  1.Generate a controller
  2.Add at least an index route for the controller
  3.rails g repack:view name_of_view (should be singular and match controller)


## Contributing

Pull requests & issues welcome. Advice & criticism regarding webpack config approach also welcome.

Please ensure that pull requests pass rspec. New functionality should be discussed in an issue first.

## Acknowledgements

* mipearson for his [webpack-rails](https://github.com/mipearson/webpack-rails) gem which inspired this implementation
