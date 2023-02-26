<template>
  <div>123</div>
</template>

<script setup>
import Web3 from "web3";

// 实例化web3
var web3 = new Web3(
  Web3.givenProvider ||
    // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
    "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
);
// console.log("web3: ", web3);

// 创建账户
const newAccount = web3.eth.accounts.create("123");
console.log("newAccount: ", newAccount);
</script>

<style lang="scss"></style>
