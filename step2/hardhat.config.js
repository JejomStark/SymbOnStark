require("@shardlabs/starknet-hardhat-plugin");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    // Define our test network, we execute on local with docker.
    networks: {
        develop: {
            url: "http://127.0.0.1:5000"
        }
    },
    cairo: {
        // Version of the plugin which is execute on the docker
        version: "0.6.2"
    },
    paths: {
        // Where are our contracts: ./contracts
        starknetSources: __dirname + "/contracts",
        // Where are our artifacts (build contract): ./stark-artifacts, not use repository "artifacts" which is reserved by hardhat to solidity
        starknetArtifacts: __dirname + "/stark-artifacts",
    },
    mocha: {
        // set up the network to run our test
        starknetNetwork: "develop"
    }
};