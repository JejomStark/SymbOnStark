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


        // account1 = await starknet.getAccountFromAddress(
        //     '0x045add989b7022ac4af9fd31833f8a77b3b6cfc9f95f9f3e53127f1c376b2d53', //accountAddress, 
        //     '0xf3130ba5bb1e4bcca75c6765b58a6fecc32a046d394b18c63ea80244aef5736', //process.env.PRIVATE_KEY, 
        //     "OpenZeppelin"
        // );
        // accountAddress = account.starknetContract.address;
        // privateKey = account.privateKey;
        // publicKey = account.publicKey;
        // console.log("Deployed account at address:", account.starknetContract.address);
        // console.log("Private and public key:", privateKey, publicKey);
        // Kitticontract = await contractKittiFactory.deploy({ admin: account1InBN });
        // Kitticontract = await contractFactory.getContractAt("0x03e2a861428057d4acff4e99f5739df09dd760a27835cc049e870c96bd23a7fc")
        // console.log('KittiAdresse', Kitticontract.address)
        const contractSymbFactory = await starknet.getContractFactory("SymbioteFactory");

        // Symbiotecontract = await contractFactory.getContractAt("0x075eecf2cb993d7c1840b9be5084ab0680dff61f4a1b247586244608122639b8")
        Symbiotecontract = await contractSymbFactory.deploy({ admin: accountAdminInBN });
        // console.log('symbAdresse', Symbiotecontract.address)
    })


    it("Should add kitti and get this informations.", async function () {
        // We need to increase the timeout to prevent test network latencies (in microseconds))  
        this.timeout(600_000);

        // const contractFactory = await starknet.getContractFactory("MyContract");
        // const contract = await contractFactory.getContractAt("0x03bc53db3645a462f3a779fa505dd0d164b8719f7b48d1068e6d772c1c7f6dba");
        await accountAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 1 }, dna: { high: 0, low: 1234567890123456 } });
        await accountAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 2 }, dna: { high: 0, low: 1234567890123789 } });

        const kitti1 = await accountAdmin.call(Kitticontract, "get_kitti", { kittiId: { high: 0, low: 1 } });
        expect(kitti1.dna.low).eq(BigInt(1234567890123456))

        const kitti2 = await accountAdmin.call(Kitticontract, "get_kitti", { kittiId: { high: 0, low: 2 } });
        expect(kitti2.dna.low).eq(BigInt(1234567890123789))
    });

    it("Should failed add kitti (not admin).", async function () {
        // We need to increase the timeout to prevent test network latencies (in microseconds))  
        this.timeout(600_000);
        try {
            await accountNotAdmin.invoke(Kitticontract, "add_kitti", { kittiId: { high: 0, low: 3 }, dna: { high: 0, low: 3334567890123456 } });
        } catch (err) {
            expect(err.message).to.contain("only admin can do that !");
        }
    });

    it("Create a random symbiote", async () => {
        // We need to increase the timeout to prevent test network latencies (in microseconds))  
        // this.timeout(600_000);

        // const contractFactory = await starknet.getContractFactory("MyContract");
        // const contract = await contractFactory.getContractAt("0x03bc53db3645a462f3a779fa505dd0d164b8719f7b48d1068e6d772c1c7f6dba");
        // await account1.invoke(Symbiotecontract, "create_random_symbiote", { name: shortString.encodeShortString('symbonstark') });
        await accountAdmin.invoke(Symbiotecontract, "set_kittis_address", { address: number.toBN(Kitticontract.address).toString() });
        const kitti1 = await accountAdmin.call(Symbiotecontract, "get_kitti_dna", { kittiId: { high: 0, low: 1 } });
        expect(kitti1.dna.low).eq(BigInt(1234567890123456))
    })
});