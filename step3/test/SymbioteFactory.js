//we import expect to test values
const { expect } = require("chai");
// These two lines allow us to play with our testnet and access our deployed contract 
const { starknet } = require("hardhat");
const { StarknetContract, StarknetContractFactory } = require("hardhat/types/runtime");
// import library to transform string<>decimal
const { starkDecode, starkEncode } = require('./librairies/string-dec')

describe("Test contract : SYMBIOTE", function () {

  it("Should create an symbiote and get this informations.", async function () {
    // We need to increase the timeout to prevent test network latencies (in microseconds))  
    this.timeout(600_000);

    console.log("Started deployment");

    // "Create our contract and deploy it
    const contractFactory = await starknet.getContractFactory("SymbioteFactory");
    const contract = await contractFactory.deploy();

    console.log("Deployed at", contract.address);
    // We create an symbiote "symb1"
    const symb1 = 'symb1'
    // we encode it
    const symb1_enc = symb1.starkEncode()
    console.log('Mint = name: ', symb1, ', decimal:', symb1_enc)

    // We call our function
    const add_symb1 = await contract.invoke("create_random_symbiote", { name: symb1_enc });
    console.log("Add symbiote", add_symb1)

    // We get our symbiote
    const { symb } = await contract.call("get_symbiote", { id: 0 });
    const dna = symb.dna.low
    const ext = dna.toString().match(/.{1,16}/g)
    console.log("Get symbiote", symb)
    // we extract our DNA
    console.log('Generate DNA', ext[0])

  });
});
