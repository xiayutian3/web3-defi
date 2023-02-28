const { defineConfig } = require("@vue/cli-service");
const { VantResolver } = require("unplugin-vue-components/resolvers");
const ComponentsPlugin = require("unplugin-vue-components/webpack");
// ethereumjs-tx@1.3.7包 需要的polyfill
const NodePolyfillWebpackPlugin = require("node-polyfill-webpack-plugin");

module.exports = defineConfig({
  transpileDependencies: true,
  configureWebpack: {
    plugins: [
      new NodePolyfillWebpackPlugin(),
      ComponentsPlugin({
        resolvers: [VantResolver()],
      }),
    ],
  },
});
