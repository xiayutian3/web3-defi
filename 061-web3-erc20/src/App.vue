<template>
  <div>
    <h1>RABTC基本信息：</h1>
    <hr />
    <p>当前账号：{{ currentAccount }}</p>
    <p>代币名称：{{ name }}</p>
    <p>代币标识：{{ symbol }}</p>
    <p>发行量：{{ totalSupply }}</p>
    <p>持有数：{{ balanceOf }}</p>
    <h1>转账操作：</h1>
    <hr />
    <p>转入地址：<input type="text" v-model="toAddress" class="address" /></p>
    <p>转出金额：<input type="text" v-model="amount" />R</p>
    <button @click="send">开始转账</button>
    <p>要转入地址：0xfB04F04e64E52371fE93a7eDc2C0661e8ce5047d</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Web3 from "web3";
import mtcJSON from "./contracts/MyToken.json";

// 实例化web3  goerli上的 我们的erc20合约地址 0x36d072a4926f181D8f034d7aAA7C9498fc948886
const web3 = new Web3(
  Web3.givenProvider ||
    // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
    "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
);

// 创建合约实例
const mtcContract = new web3.eth.Contract(
  mtcJSON.abi,
  "0x36d072a4926f181D8f034d7aAA7C9498fc948886"
);

// 获取代币信息
const name = ref("");
const symbol = ref("");
const totalSupply = ref(0);
const balanceOf = ref(0);
const currentAccount = ref("");

const getCoinInfo = async () => {
  // 链接账户地址(登录账户)
  const account = await web3.eth.requestAccounts();
  currentAccount.value = account[0];
  // console.log("account: ", account);

  name.value = await mtcContract.methods.name().call(); //call调用，不消耗gas，不改变数据，只读方法
  symbol.value = await mtcContract.methods.symbol().call(); //call调用，不消耗gas，不改变数据，只读方法
  //转化一下单位 web3.utils.fromWei
  totalSupply.value = web3.utils.fromWei(
    await mtcContract.methods.totalSupply().call()
  ); //call调用，不消耗gas，不改变数据，只读方法
  balanceOf.value = web3.utils.fromWei(
    await mtcContract.methods.balanceOf(account[0]).call()
  ); //call调用，不消耗gas，不改变数据，只读方法
};

// 转账信息(转入地址,转出金额)
const toAddress = ref("");
const amount = ref("");
// 转账函数（转发代币）---调用合约转账函数
const send = () => {
  const weiAmount = web3.utils.toWei(amount.value, "ether");
  // console.log("weiAmount: ", weiAmount);
  mtcContract.methods
    .transfer(toAddress.value, weiAmount)
    .send({
      //修改区块链上的数据，消耗gas，
      from: currentAccount.value,
    })
    .on("receipt", (receipt) => {
      console.log("交易成功receipt: ", receipt);
    });
};

onMounted(() => {
  getCoinInfo();
});
</script>

<style lang="scss">
.address {
  width: 500px;
}
</style>
