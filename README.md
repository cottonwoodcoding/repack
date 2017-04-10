# Repack

**Repack** gives you tools to integrate Webpack and React in to an existing Ruby on Rails application.

It will happily co-exist with sprockets but does not use it for production fingerprinting or asset serving. **Repack** is designed with the assumption that if you're using Webpack you treat Javascript as a first-class citizen. This means that you control the webpack config, package.json, and use npm to install Webpack & its plugins.

In development mode [webpack-dev-server](http://webpack.github.io/docs/webpack-dev-server.html) is used to serve webpacked entry points and offer hot module reloading. In production entry points are built in to `public/client`. **Repack** uses [stats-webpack-plugin](https://www.npmjs.com/package/stats-webpack-plugin) to translate entry points in to asset paths.

It was forked from the [Marketplacer](http://www.marketplacer.com) repo: (https://github.com/mipearson/webpack-rails) and support for React / Babel / ES6 was added.

This gem has been tested against Rails 5 and Ruby 2.3.1 Earlier versions of Rails (>= 3.2) and Ruby (>= 1.9) may work, but we haven't tested them.

## Using Repack

### Install Options

  1. Basic Install: `bundle exec rails g repack:install` -> Webpack / React
  2. React / Redux Install: `bundle exec rails g repack:redux_install` -> Webpack / React / Redux Boilerplate
  3. React / Router Install: `bundle exec rails g repack:router_install` -> Webpack / React / React Router Boilerplate
  4. React / Router / Redux Install: `bundle exec rails g repack:router_redux_install` -> Webpack / React / Router / Redux Boilerplate
  5. GOD MODE: `bundle exec rails g repack:god_install` -> Webpack / React / React Router / Redux / Devise / Devise Token Auth / Bootstrap or Materialize Boilerplate.

### Installation

  1. Add `repack` to your gemfile
  2. Run `bundle install` to install the gem
  3. See `Install Options` above and use 1 option
  4. Run `npm run dev_server` (or `yarn run dev_server`) to start `webpack-dev-server`
  5. Add the webpack entry point to your layout (see next section)
  6. Edit `client/application.js` and write some code

### Adding the entry point to your Rails application

To add your webpacked javascript in to your app, add the following to the `<body>` section of any layout by default it has been added to `application.html.erb`:

```erb
<%= javascript_include_tag *webpack_asset_paths("application") %>
```

Take note of the splat (`*`): `webpack_asset_paths` returns an array, as one entry point can map to multiple paths, especially if hot reloading is enabled in Webpack.

#### Use with webpack-dev-server live reload

If you're using the webpack dev server's live reload feature (not the React hot reloader), you'll also need the following in your layouts/application template:

``` html
<script src="http://localhost:3808/webpack-dev-server.js"></script>
```

**This has been added to layouts/application.html.erb by default.**

### Configuration Defaults

  * Webpack configuration lives in `config/webpack.config.js`
  * Webpack & Webpack Dev Server binaries are in `node_modules/.bin/`
  * Webpack Dev Server will run on port 3808 on localhost via HTTP
  * Webpack Dev Server is enabled in development & test, but not in production
  * Webpacked assets will be compiled to `public/client`
  * The manifest file is named `manifest.json`

## View Generator

1. Generate a controller
2. Add at least an index route for the controller
3. rails g repack:view name_of_view (should match controller name)

EXAMPLE:
``` bash
rails g controller Admin index
rails g repack:view admin
```

NOTE: The view generator will try to match its argument to a currently existing controller name, but if a controller cannot be found with that name, the generator will follow typical Rails convention and pluralize the view directory being created.

In an example where I have an AdminController &  SessionsController:

``` bash
rails g repack:view admin
(will find the AdminController and create views/admin/index.html.erb)

rails g repack:view sessions
(will find the SessionsController and create views/sessions/index.html.erb)

rails g repack:view user
(will not find a controller, will follow Rails controller naming convention and create views/users/index.html.erb)
```

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

An alternative to adding the post build hook to `package.json` is to add `rake repack:compile` to your deployment. It serves a similar purpose as Sprockets' `assets:precompile` task. If you're using Webpack and Sprockets (as we are at Marketplacer) you'll need to run both tasks - but it doesn't matter which order they're run in.

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

## Contributing

Pull requests & issues welcome. Advice & criticism regarding webpack config approach also welcome.

Please ensure that pull requests pass rspec. New functionality should be discussed in an issue first.

## Acknowledgements

* mipearson for his [webpack-rails](https://github.com/mipearson/webpack-rails) gem which inspired this implementation
