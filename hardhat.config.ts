import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",


  networks: {
    hardhat: {
      forking: {
        enabled: true,
        url: "https://eth-mainnet.g.alchemy.com/v2/rtlxxes_98Ymred3mrPqUxbq2gx9VcMK",
      },
      // gas: 2100,
    },
    goerli: {
      url: process.env.GOERLI_RPC,
      //@ts-ignore
      accounts: [process.env.PRIVATE_KEY, process.env.PRIVATE_KEY2],
    }
  },
  etherscan:{
    apiKey: process.env.API_KEY,
  },
};

export default config;
