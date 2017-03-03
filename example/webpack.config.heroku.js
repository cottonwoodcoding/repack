// Example webpack configuration with asset fingerprinting in production.
'use strict';

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var autoprefixer = require('autoprefixer');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGET=production on the environment to add asset fingerprints
var production = process.env.NODE_ENV === 'production';

var config = {
  entry: {
    // Sources are expected to live in $app_root/webpack
    'application': './client/application.js'
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'client'),
    publicPath: '/client/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  resolve: {
    extensions: ["", ".js", ".jsx", ".es6"]
  },

  module: {
    rules: [
      {
        test: /\.jsx?$/,         // Match both .js and .jsx files
        exclude: /node_modules/,
        loader: "babel-loader",
        include: [ path.join(__dirname, "..", "client")],
        options: { cacheDirectory: true }
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'url-loader',
        include: [ path.join(__dirname, "..", "client")],
        options: {
          limit: 25000
        }
      },
      {
         test: /\.scss$/,
         use: [
           { loader: "style-loader", query: { sourceMap: true }},
           {
             loader: "css-loader",
             query: {
               modules: true,
               importLoaders: true,
               localIdentName: '[local]___[hash:base64:5]'
             }
           },
           { loader: "sass-loader" },
           { loader: "postcss-loader" }
         ],
         exclude: /node_modules/,
         include: [ path.join(__dirname, "..", "client")],
      }
    ]
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new webpack.LoaderOptionsPlugin({ options: { postcss: [ autoprefixer ] }}),
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    }),
    new ExtractTextPlugin({ filename: 'bundle.css', allChunks: true })
  ]
};

if (production) {
  config.plugins.push(
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') }
    }),
    new webpack.optimize.DedupePlugin()
  );
} else {
  config.devServer = {
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  config.output.publicPath = '//localhost:' + devServerPort + '/client/';
  // Source maps
}

module.exports = config;
