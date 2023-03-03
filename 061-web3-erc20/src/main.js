import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

createApp(App).use(store).use(router).mount("#app");

if (typeof window.ethereum !== "undefined") {
  console.log("MetaMask is installed!");
}
