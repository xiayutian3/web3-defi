<template>
  <h1>{{ str }}</h1>
  <van-button type="primary">12345</van-button>
  <web3Api></web3Api>
</template>

<script setup>
import { ref } from "vue";
import Web3 from "web3";
import web3Api from "./components/Web3Api.vue";

const str = ref("hello123");

// 实例化web3
// eslint-disable-next-line no-unused-vars
var web3 = new Web3(
  Web3.givenProvider ||
    // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
    "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
);
// console.log("web3: ", web3);
</script>

<style lang="scss"></style>
