require("@shardlabs/starknet-hardhat-plugin");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    starknet: {
        dockerizedVersion: "0.7.0",
        network: "develop",
        wallets: {
            // You need to deploy account with : npx hardhat starknet-deploy-account --starknet-network develop  --wallet hhWallet
            hhWallet: {
                accountName: "hhWallet",
                modulePath: "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
                accountPath: "~/.starknet_accounts"
            }
        }
    },
    // Define our test network, we execute on local with docker.
    networks: {
        develop: {
            url: "http://127.0.0.1:5000"
        }
    },
    cairo: {
        // Version of the plugin which is execute on the docker
        version: "0.7.0"
    },
    paths: {
        // Where are our contracts: ./contracts
        starknetSources: __dirname + "/contracts",
        // Where are our artifacts (build contract): ./stark-artifacts, not use repository "artifacts" which is reserved by hardhat to solidity
        starknetArtifacts: __dirname + "/stark-artifacts",
        // Same purpose as the `--cairo-path` argument of the `starknet-compile` command
        // Allows specifying the locations of imported files, if necessary.
        cairoPaths: [
            "/workspace/cairo/starknet-l2-storage-verifier/contracts"
        ]
    },
    mocha: {
        // set up the network to run our test
        starknetNetwork: "develop"
    }
};