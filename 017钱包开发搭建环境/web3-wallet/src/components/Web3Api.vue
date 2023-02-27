<template>
  <div>
    <h1>账户信息</h1>
    <p>账户地址：{{ address }}</p>
    <p>账户私钥：{{ privateKey }}</p>
    <p>余额：{{ amount }}</p>
    <h1>转账操作</h1>
    <van-button type="primary" @click="send">开始转账</van-button>
  </div>
</template>

<script setup>
import { ref } from "vue";
import Web3 from "web3";
// npm i ethereumjs-tx@1.3.7
// eslint-disable-next-line no-unused-vars
import Tx from "ethereumjs-tx";

// 实例化web3
var web3 = new Web3(
  Web3.givenProvider ||
    // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
    "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
);
// console.log("web3: ", web3);

// 创建账户（每执行一次就创建一个新的账户）
// const newAccount = web3.eth.accounts.create("123");
// console.log("newAccount: ", newAccount);
//生成的账户
const address = ref("0x2AB6c26193B3805bbc9fE5E5cB3666b4534a6105");
const privateKey = ref(
  "0x78a1b330da6edebd1735ca04fe14c84a9251a24d68238e947f28ad027bc942fc"
);
//查询余额(连接以太坊goerli测试网，不翻墙，没法获取余额)
const amount = ref(0);
web3.eth.getBalance(address.value).then((res) => {
  // console.log("res: ", res);
  amount.value = res;
});

// 单位转换
// const num1 = Web3.utils.toWei("0.3"); //类上面也存在方法
// const num2 = web3.utils.toWei("0.3"); //实例上也存在方法
const num3 = Web3.utils.fromWei(3 * 10 ** 18 + "", "ether");
const num4 = web3.utils.fromWei(3 * 10 ** 18 + "", "ether");
console.log("num: ", num3, num4);

// 转账操作
const send = async () => {
  // 1.构建转账参数
  // 获取账户的交易次数
  let nonce = await web3.eth.getTransactionCount(address.value);
  // 获取预计转账 gas 费
  let gasPrice = await web3.eth.getGasPrice();
  // console.log("gasPrice: ", gasPrice);
  // 转账金额都以 wei为单位
  let value = await web3.utils.toWei("0.01");
  // 数据对象
  // eslint-disable-next-line no-unused-vars
  let rawTx = {
    from: address.value,
    to: "0x7Ef611ccad8431c7559B66a0CA71fB7264964A13",
    nonce,
    gasPrice,
    value,
    data: "0x0000", //转Token代币会用到的一个字段
  };

  //2.生成 serializeTx
  // 转化私钥 16进制
  const privateKeyBuffer1 = Buffer(privateKey.value.slice(2), "hex"); //转化出来是一样的结果
  console.log("privateKeyBuffer1: ", privateKeyBuffer1);
  // const privateKeyBuffer = Buffer.from(privateKey.value.slice(2), "hex");
  // console.log("privateKeyBuffer: ", privateKeyBuffer);

  // gas 估算
  const gas = await web3.eth.estimateGas(rawTx);
  console.log("gas: ", gas, gasPrice, value);
  // console.log(amount.value > gas * gasPrice + value);
  rawTx.gas = gas;

  // ethereumjs-tx@1.3.7实现私钥加密
  const tx = new Tx(rawTx);
  tx.sign(privateKeyBuffer1);
  // 生成 serializedTx
  const serializedTx = tx.serialize();
  // console.log("serializedTx: ", serializedTx);

  // // 3.开始转账
  const trans = web3.eth.sendSignedTransaction(
    "0x" + serializedTx.toString("hex")
  );
  // 在交易发出并得到有效的交易哈希后立刻触发
  trans.on("transactionHash", (txid) => {
    console.log("交易的id ", txid);
    console.log(`https://goerli.etherscan.io/tx/${txid}`);
  });
  // 当收到交易收据后立刻触发,第一个节点确认，只要有一个节点确认就结束了，只有一次
  trans.on("receipt", (receipt) => {
    console.log("receipt: ", receipt);
  });
  // 每次节点确认后立刻触发（除第一次触发外）
  trans.on("confirmation", () => {
    console.log("每次确认后立刻触发 ");
  });
};
</script>

<style lang="scss"></style>
