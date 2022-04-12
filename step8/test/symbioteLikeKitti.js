//we import expect to test values
const { expect } = require("chai");
// These two lines allow us to play with our testnet and access our deployed contract 
const { starknet } = require("hardhat");
const { StarknetContract, StarknetContractFactory } = require("hardhat/types/runtime");
const { defaultProvider, number, shortString } = require('starknet');

describe("Test contract : Kittis", () => {

    let accountAdmin, accountNotAdmin, Kitticontract, Symbiotecontract

    before(async () => {

        // We initialize 2 accounts : one to our admin and another to test our add function.
        accountAdmin = await starknet.deployAccount("OpenZeppelin");
        accountNotAdmin = await starknet.deployAccount("OpenZeppelin");

        // We need to transforme in Big Number our address 
        const accountAdminInBN = number.toBN(accountAdmin.starknetContract.address).toString()

        // We deploy our Kitti contract with the admin address in param
        const contractKittiFactory = await starknet.getContractFactory("Kittis");
        Kitticontract = await contractKittiFactory.deploy({ admin: accountAdminInBN });
        
        const contractSymbFactory = await starknet.getContractFactory("SymbioteFactory");
        Symbiotecontract = await contractSymbFactory.deploy({ admin: accountAdminInBN });
    })


    it("Should add kitti and get this informations.", async function () {
        await accountAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 1 }, dna: { high: 0, low: 1234567890123456 } });
        await accountAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 2 }, dna: { high: 0, low: 1234567890123789 } });

        const kitti1 = await accountAdmin.call(Kitticontract, "get_kitti", { kittiId: { high: 0, low: 1 } });
        expect(kitti1.dna.low).eq(BigInt(1234567890123456))

        const kitti2 = await accountAdmin.call(Kitticontract, "get_kitti", { kittiId: { high: 0, low: 2 } });
        expect(kitti2.dna.low).eq(BigInt(1234567890123789))
    });

    it("Should failed add kitti (not admin).", async function () {
        try {
            await accountNotAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 3 }, dna: { high: 0, low: 3334567890123456 } });
        } catch (err) {
            expect(err.message).to.contain("only admin can do that !");
        }
    });

    it("Get the DNA of Kitti(1) into Symbiote contract", async () => {
        await accountAdmin.invoke(Symbiotecontract, "set_kittis_address", { address: number.toBN(Kitticontract.address).toString() });
        const kitti1 = await accountAdmin.call(Symbiotecontract, "get_kitti_dna", { kittiId: { high: 0, low: 1 } });
        expect(kitti1.dna.low).eq(BigInt(1234567890123456))
    })
});
