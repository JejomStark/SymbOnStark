//we import expect to test values
const { expect } = require("chai");
// These two lines allow us to play with our testnet and access our deployed contract 
const { starknet } = require("hardhat");
const { StarknetContract, StarknetContractFactory } = require("hardhat/types/runtime");


describe("Test contract : Balance", function () {

  it("Should create an contract and play with it.", async function () {
    // We need to increase the timeout to prevent test network latencies (in microseconds))  
    this.timeout(600_000);

    console.log("Started deployment");

    // "Balance" represent our smart contract.
    const contractFactory = await starknet.getContractFactory("Balance");
    const contract = await contractFactory.deploy({ initial_balance: 0 });

    console.log("Deployed at", contract.address);

    const { res: BalanceBefore } = await contract.call("get_balance");
    console.log("balance at initialization", BalanceBefore)
    expect(BalanceBefore).to.equal(BigInt("0")); // or 0n, the return is typeOf Bigint

    await contract.invoke("increase_balance", { amount: 10 });
    console.log("Balance Increased by 10");

    const { res: balanceAfter } = await contract.call("get_balance");
    console.log("balance after update", balanceAfter)
    expect(balanceAfter).to.equal(10n); // or BigInt("10")
  });
});