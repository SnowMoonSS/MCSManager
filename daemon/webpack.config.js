const path = require("path");
const nodeExternals = require("webpack-node-externals");

/**
 * @type {import('webpack').Configuration}
 */
module.exports = {
  mode: "production",
  entry: "./src/app.ts",
  module: {
    rules: [
      {
        test: /\.ts/,
        use: "ts-loader",
        exclude: /node_modules/
      },
      {
        // formidable v2 (nested inside koa-body) loads its plugins via a dynamic
        // `require(path.join(...))` that webpack cannot trace. This loader rewrites
        // it into a statically-analyzable form so the plugin files get bundled into
        // app.js. See webpack/formidable-plugin.loader.js.
        test: /node_modules[\\/](?:koa-body[\\/]node_modules[\\/])?formidable[\\/]src[\\/]Formidable\.js$/,
        loader: path.resolve(__dirname, "webpack/formidable-plugin.loader.js")
      }
    ]
  },
  target: "node",
  devtool: "source-map",
  optimization: {
    chunkIds: "named",
    minimize: false,
    mangleExports: false,
    moduleIds: "named"
  },
  externalsPresets: { node: true },
  externals: [
    nodeExternals({
      allowlist: ["mcsmanager-common"]
    })
  ],
  output: {
    filename: "app.js",
    path: path.resolve(__dirname, "production")
  },
  resolve: {
    extensions: [".ts", ".js"],
    alias: {
      "@languages": path.resolve(__dirname, "../languages"),
      "mcsmanager-common": path.resolve(__dirname, "../common/src/index.ts")
    }
  }
};
