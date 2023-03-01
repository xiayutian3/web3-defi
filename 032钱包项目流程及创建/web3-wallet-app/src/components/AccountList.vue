<template>
  <div>
    <van-cell
      :title="item.address"
      icon="user-o"
      v-for="item in walletInfoAddressFilter"
      :key="item.id"
    >
      <template #right-icon>
        <van-button size="small" @click="getPassword(item.keyStore)">{{
          Number(item.balance).toFixed(5)
        }}</van-button>
      </template>
    </van-cell>
    <van-dialog
      v-model:show="show"
      title="请输入密码"
      show-cancel-button
      @confirm="confirmPassword"
    >
      <van-cell-group inset>
        <van-field
          v-model="password"
          label="密码"
          placeholder="请输入密码"
          type="password"
        />
        <van-field
          v-model="toaddress"
          label="转入账户"
          placeholder="请输入转入账户"
        />
        <van-field
          v-model="number"
          label="转出金额（单位以太）"
          placeholder="请输入转出金额"
        />
      </van-cell-group>
    </van-dialog>
  </div>
</template>

<script setup>
import { ref, defineProps, computed } from "vue";
import Web3 from "web3";
// npm i ethereumjs-tx@1.3.7
import Tx from "ethereumjs-tx";
import ethwallet from "ethereumjs-wallet";

const props = defineProps(["walletInfo"]);
// console.log("props: ", props.walletInfo);
const show = ref(false);
const password = ref("");
const keyStore = ref("");
const toaddress = ref("");
const number = ref(0);

// 实例化web3
var web3 = new Web3(
  Web3.givenProvider ||
    // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
    "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
);

//重新计算地址，改为省略号表示
const walletInfoAddressFilter = computed(() => {
  return props.walletInfo.map((item) => {
    //获取账号余额
    web3.eth.getBalance(item.address).then((res) => {
      item.balance = web3.utils.fromWei(res, "ether"); //转成以太单位
    });
    item.address = item.address.slice(0, 8) + "..." + item.address.slice(-4);
    return item;
  });
});

// 转账操作
const send = async (keystore, password) => {
  // keyStore + 密码-》  反解出私钥和地址
  let walletObj;
  try {
    //获取钱包对象
    walletObj = await ethwallet.fromV3(keystore, password);
  } catch (error) {
    alert("密码错误");
    return false;
  }
  // 私钥 (这里获得私钥 不是以0x开头的)
  let privateKey = walletObj.getPrivateKey().toString("hex");
  //转化成buffer数据 新版buffer不用new(这一步下面有，这里就不需要了)
  // const privateKey = Buffer(key, "hex");
  // 钱包账户地址(可以通过 walletObj 获取，也可以传进来，因为传进的props.walletInfo数组中已经有地址了)
  const fromaddress = walletObj.getAddressString();
  // console.log("fromaddress: ", fromaddress);

  // 1.构建转账参数
  // 获取账户的交易次数
  let nonce = await web3.eth.getTransactionCount(fromaddress);
  // 获取预计转账 gas 费
  let gasPrice = await web3.eth.getGasPrice();
  // console.log("gasPrice: ", gasPrice);
  // 转账金额都以 wei为单位
  let value = await web3.utils.toWei(number.value);
  // 数据对象
  // eslint-disable-next-line no-unused-vars
  let rawTx = {
    from: fromaddress,
    to: toaddress.value,
    nonce,
    gasPrice,
    value,
    data: "0x0000", //转Token代币会用到的一个字段
  };

  //2.生成 serializeTx
  // 转化私钥 16进制  第一个参数不是0x开头的私钥
  const privateKeyBuffer1 = Buffer(privateKey, "hex"); //转化出来是一样的结果
  console.log("privateKeyBuffer1: ", privateKeyBuffer1);
  // const privateKeyBuffer = Buffer.from(privateKey, "hex");
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
  // 错误事件
  trans.on("error", console.error); //
};

//先输入密码，在完成转账
const getPassword = (keystore) => {
  keyStore.value = keystore;
  show.value = true;
};

// 密码输入后的确认事件
const confirmPassword = () => {
  send(keyStore.value, password.value);
  password.value = "";
};
</script>

<style lang="scss"></style>
