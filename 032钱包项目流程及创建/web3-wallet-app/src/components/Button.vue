<template>
  <div>
    <van-space>
      <van-button type="primary" @click="createWallet">创建钱包</van-button>
      <van-button type="primary">导入钱包</van-button>
    </van-space>
    <template v-if="showMn">
      <p class="mnemonic">{{ mnemonic }}</p>
      <van-button size="mini" @click="confirmSaveMnemonic"
        >我已经保存</van-button
      >
    </template>

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
      </van-cell-group>
    </van-dialog>
    <van-dialog
      v-model:show="showMnDialog"
      title="请输入助记词"
      show-cancel-button
      @confirm="confirmMn"
    >
      <van-cell-group inset>
        <van-field
          v-model="mnemonic2"
          label="助记词"
          placeholder="请输入助记词"
        />
      </van-cell-group>
    </van-dialog>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { showNotify } from "vant";
import * as bip39 from "bip39";
import { hdkey } from "ethereumjs-wallet";
import store2 from "store2";
import "vant/es/notify/style";

const show = ref(false);
const password = ref("");
const mnemonic = ref("");
const showMn = ref(false);
const showMnDialog = ref(false);
const mnemonic2 = ref("");

// 创建钱包
const createWallet = () => {
  show.value = true;
};
// dialog确认按钮（使用助记词的方法创建账号- bip39）
const confirmPassword = () => {
  if (!password.value) {
    // 危险通知
    showNotify({ type: "danger", message: "请输入密码" });
  } else {
    //如果存在账号数据，说明已经有助记词了,就不需要在生成助记词了
    const walletInfo = store2("walletInfo");
    if (walletInfo) {
      mnemonic.value = walletInfo[0]["mnemonic"];
      //直接生成钱包账户
      generateWalletAccount();
    } else {
      //生成助记词
      // junk cycle shadow silent motor area pluck gorilla cake swear dirt divert
      mnemonic.value = bip39.generateMnemonic();
      showMn.value = true;
    }
  }
  console.log(password.value);
};

// 保存助记词按钮
const confirmSaveMnemonic = () => {
  showMnDialog.value = true;
};
// 助记词输入确认按钮
const confirmMn = async () => {
  showMn.value = false;
  if (mnemonic.value == mnemonic2.value) {
    generateWalletAccount();
  }
};

// 钱包账户生成逻辑
const generateWalletAccount = async () => {
  //接下来开始创建钱包账户
  // 生成种子
  const seed = await bip39.mnemonicToSeed(mnemonic.value);
  // 生成分层钱包
  const hdWallet = hdkey.fromMasterSeed(seed);
  // 生成密钥对
  const walletInfo2 = store2("walletInfo") || [];
  const addressIndex = walletInfo2.length ? walletInfo2.length : 0;
  const keyPair = hdWallet.derivePath(`m/44'/60'/0'/0/${addressIndex}`);
  // 生成钱包
  const wallet = keyPair.getWallet();

  // 获取钱包账户地址
  const lowerCaseAddress = wallet.getAddressString();
  // 获取钱包账户校验地址
  const CheckSumAddress = wallet.getChecksumAddressString();
  // 获取账户私钥
  const privateKey = wallet.getPrivateKey().toString("hex");
  // 获取账户keystore
  const keyStore = await wallet.toV3(password.value);

  // 聚集钱包账户信息,因为可能一个助记词管理多个账户，所以使用数组
  const walletInfoObj = {
    id: addressIndex, //钱包index
    address: lowerCaseAddress, //账户地址
    privateKey: privateKey, //私钥
    keyStore: keyStore, //钱包keyStore
    mnemonic: mnemonic.value, //助记词
    balance: 0, //余额
  };
  walletInfo2.push(walletInfoObj);
  //存储数据到本地
  store2("walletInfo", walletInfo2);
};
</script>

<style lang="scss">
.mnemonic {
  user-select: all;
}
</style>
