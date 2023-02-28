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
    //生成助记词
    // junk cycle shadow silent motor area pluck gorilla cake swear dirt divert
    mnemonic.value = bip39.generateMnemonic();
    showMn.value = true;
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
    //接下来开始创建钱包账户
    // 生成种子
    const seed = await bip39.mnemonicToSeed(mnemonic.value);
    // 生成分层钱包
    const hdWallet = hdkey.fromMasterSeed(seed);
  }
};
</script>

<style lang="scss">
.mnemonic {
  user-select: all;
}
</style>
