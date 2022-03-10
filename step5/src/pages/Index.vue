<template>
  <q-page class="flex flex-center">
    <q-btn color="dark" @click="connectWallet" v-if="!connected">
      <q-icon left size="2em" name="account_balance_wallet" />
      <div>Connect wallet</div>
    </q-btn>
    <q-btn color="dark" @click="checkIfOwnerHaveMinted" v-if="connected">
      <q-icon left size="2em" name="description" />
      <div>Check mint</div>
    </q-btn>
    <q-btn color="dark" @click="mint" v-if="connected" class="q-ma-md">
      <q-icon left size="2em" name="rocket_launch" />
      <div>Mint my symbiote</div>
    </q-btn>
  </q-page>
</template>

<script>
import { defineComponent } from "vue";
import { getStarknet } from "@argent/get-starknet";
import { stark, shortString, number } from "starknet";
const { getSelectorFromName } = stark;

export default defineComponent({
  name: "PageIndex",
  data() {
    return {
      contract:
        "0x063e7a28f41937c2e59c5857bb38f5760a2b7e8f7ab943e44b3c454bc0482371",
      connected: false,
      wallet: null,
      starknet: null,
      hasMinted: 0,
    };
  },
  methods: {
    async connectWallet() {
      this.starknet = getStarknet();
      try {
        const [userWalletContractAddress] = await this.starknet.enable({
          showModal: true,
        });
        console.log("wallet's informations", userWalletContractAddress);
        this.wallet = userWalletContractAddress;
      } catch (e) {
        console.log("Error detected", e);
      }
      // Check if connection was successful
      if (this.starknet.isConnected) {
        console.log("connected", true);
        this.connected = true;
      }
    },
    async checkIfOwnerHaveMinted() {
      // We call the contract to check existence or get our symbiote
      console.log("Calling contract", this.contract);
      const hasMinted = await this.starknet.provider.callContract({
        contract_address: this.contract,
        entry_point_selector: getSelectorFromName("check_owner_mint"),
        calldata: [number.toBN(this.wallet).toString()],
      });
      this.hasMinted = parseInt(number.hexToDecimalString(hasMinted.result[0]));
      console.log("Has minted", this.hasMinted);
    },
    async mint() {
      try {
        const nameSymbiote = "demosymb";
        // we encode the name
        const name = shortString.encodeShortString(nameSymbiote);
        // We sign our transaction with argentX wallet and we call our function "create_random_symbiote"
        console.log("Mint my symbiote");
        const symb = await this.starknet.signer.addTransaction({
          type: "INVOKE_FUNCTION",
          contract_address: this.contract,
          entry_point_selector: getSelectorFromName("create_random_symbiote"),
          calldata: [name],
        });
        console.log("Show invoke", symb);

        console.log("wait while the transaction is not accepted or rejected");
        const status = await this.checkTxStatus(symb.transaction_hash);
        console.log("Show my tx status", status.tx_status);
        console.log(status);
        if (status.tx_status === "REJECTED") {
          console.log(
            "Show error information",
            status.tx_failure_reason.error_message
          );
        } else {
          // NOTA: Actualy the invoke function doesn't return data
          console.log("Call the contract to get symbiote's informations");
          const dataSymbiote = await this.starknet.provider.callContract({
            contract_address: this.contract,
            entry_point_selector: getSelectorFromName("get_symb_of"),
            calldata: [number.toBN(this.wallet).toString()],
          });
          const mySymb = {
            id: parseInt(number.hexToDecimalString(dataSymbiote.result[0])),
            name: shortString.decodeShortString(dataSymbiote.result[2]),
            dna: number.hexToDecimalString(dataSymbiote.result[3]).toString(),
          };
          console.log("Symbiote's informations", mySymb);
        }
      } catch (e) {
        console.log("### erreur", e);
      }
    },
    async checkTxStatus(tx) {
      let accepted = false;
      let statusTx = null;
      do {
        await this.sleep(5000);
        // We check the status on starknet network
        const status = await this.starknet.provider.getTransactionStatus(tx);
        // We check if status is ACCEPTED_ON_L2|REJECTED that's informed us when interaction with contract has done
        accepted = this.STATE_VALID_L2.includes(status.tx_status);
        statusTx = status;
      } while (accepted === false);
      return statusTx;
    },
    /**
     * Function to sleep during "ms" time
     */
    async sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
  },
  created() {
    this.STATE_VALID_L2 = ["ACCEPTED_ON_L2", "REJECTED"];
  },
});
</script>
