<template>
  <div>
    <h1>助记词</h1>
    <p>{{ mnemonic }}</p>
    <h1>分层钱包路径</h1>
    <p>"m/44'/60'/0'/0/0"</p>
    <h1>账户地址</h1>
    <p>0xdaf944b83007b96116e439e509263136b9b4cd49</p>
    <h1>账户私钥</h1>
    <p>73557a4119e530f5de622fb699bfbbf85c568aa52bb27203bf30182fb924ed41</p>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { generateMnemonic, mnemonicToSeed } from "bip39";
import ethwallet, { hdkey } from "ethereumjs-wallet";
import Web3 from "web3";

// 创建助记词
let mnemonic = ref(
  "juice save fine squeeze tiny tunnel nest check matrix share soda deal"
);
// mnemonic.value = generateMnemonic();
// console.log("mnemonic.value: ", mnemonic.value);

// 生成密钥对 keypair

const genMnemonic = async () => {
  // 生成种子
  const seed = await mnemonicToSeed(mnemonic.value);
  // 生成多层钱包（HD钱包）
  const hdWallet = hdkey.fromMasterSeed(seed);
  // 传入钱包路径生成密钥对
  const keypair = hdWallet.derivePath("m/44'/60'/0'/0/0");

  // 获取私钥
  // 1.获取钱包对象
  const wallet = keypair.getWallet();
  // 2.获取钱包地址
  const lowerCaseAddress = wallet.getAddressString();
  // 3.获取钱包校验地址
  const checkAddress = wallet.getChecksumAddressString();
  // 4.获取私钥
  const priKey = wallet.getPrivateKey().toString("hex");

  // ************************************************************************************************
  // 导出keyStore(json格式,两种方式生成的keystore类似，不是完全一样)
  // 第一种方式web3js
  // 实例化web3
  var web3 = new Web3(
    Web3.givenProvider ||
      // 在这里获取测试网 goerli地址  https://app.infura.io/dashboard/ethereum/ebace207d26e4e489a31dc073732b8cc/settings
      "wss://goerli.infura.io/ws/v3/ebace207d26e4e489a31dc073732b8cc"
  );
  const keyStore = web3.eth.accounts.encrypt(priKey, "123456");
  // console.log("生成keyStore: ", JSON.stringify(keyStore));

  // 第二种获取keystore  通过钱包wallet 对象
  const keystore2 = await wallet.toV3("123456");
  // console.log("keystore2: ", JSON.stringify(keystore2));

  // 通过keystore获取私钥
  // 1.web3js
  const res = await web3.eth.accounts.decrypt(keyStore, "123456");
  // console.log("res: ", res);
  // 2.wallet
  const wallet2 = await ethwallet.fromV3(keystore2, "123456");
  const key = wallet2.getPrivateKey().toString("hex");
  // console.log("key: ", key);

  // 通过私钥获取地址 (第一个参数不是0x开头)
  const priKey2 = Buffer(priKey, "hex");
  const wallet3 = ethwallet.fromPrivateKey(priKey2);
  // 获取账户地址
  const lowerCaseAddress2 = wallet3.getAddressString();
  console.log("lowerCaseAddress2: ", lowerCaseAddress2);
};
genMnemonic();
</script>

<style lang="scss"></style>
