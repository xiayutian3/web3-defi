<template>
  <ButtonVue></ButtonVue>
  <AccountList :walletInfo="walletInfo"></AccountList>
</template>

<script setup>
import { ref, onMounted } from "vue";
import store2 from "store2";
import ButtonVue from "./components/Button.vue";
import AccountList from "./components/AccountList.vue";

const walletInfo = ref([]);

onMounted(() => {
  //获取本地存储的账号信息
  walletInfo.value = store2("walletInfo");
});
</script>

<style lang="scss">
body {
  padding: 10px;
}
</style>
