import { ethers, network } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import hre from "hardhat";
import { BigNumber } from "ethers";

async function main() {
    const [owner, holder1, holder2, holder3] = await ethers.getSigners();
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const DAIHolder = "0xb527a981e1d415AF696936B3174f2d7aC8D11369";
    //const LinkHolder = "0x0757e27AC1631beEB37eeD3270cc6301dD3D57D4";
    const UsdcHolder = "0xDa9CE944a37d218c3302F6B82a094844C6ECEb17";
    const UNIHolder = "0x47173B170C64d16393a52e6C480b3Ad8c302ba1e";
   // const Link = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
    const UNI ="0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984";
    const Usdc ="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";

    const swapD = await ethers.getContractFactory("swapDex");
    const swapDex = await swapD.deploy();
    await swapDex.deployed();

    const swapDexaddress = swapDex.address;

    console.log(`TOKEN SWAP CONTRACT IS DEPLOYED TO ${swapDexaddress}`);


    
    ///////////////////////////////////////////
    // impersonation.

    const helpers = require("@nomicfoundation/hardhat-network-helpers");
    const address = DAIHolder;
    const address3 = UsdcHolder;
    const address4 = UNIHolder;
    await helpers.impersonateAccount(address);
    await helpers.impersonateAccount(address3);
    await helpers.impersonateAccount(address4);

    await helpers.setBalance(address, 10000000000000000000000000);
    await helpers.setBalance(address3, 10000000000000000000000000);
    await helpers.setBalance(address4, 10000000000000000000000000);


    const impersonatedSigner = await ethers.getSigner(address);
    const impersonatedSigner3 = await ethers.getSigner(address3);
    const impersonatedSigner4 = await ethers.getSigner(address4);

    console.log(`IMPERSONATION COMPLETED`);
        ////////////////////////////////////////
    //ADD INTERFACE
    /////////////////////////////////////////
    const dai = await ethers.getContractAt("IUSDT", DAI);
    const usdc = await ethers.getContractAt("IUSDT", Usdc);
    const uni = await ethers.getContractAt("IUSDT", UNI);


    //////////////////////////////////////////
    // GRANT ALLOWANCE
    /////////////////////////////////////////
    const allowanceValue = await ethers.utils.parseEther("50");
    const daiAllowance = dai.connect(impersonatedSigner).approve(swapDexaddress, allowanceValue);
    const usdcAllowance = usdc.connect(impersonatedSigner3).approve(swapDexaddress, allowanceValue);
    const uniAllowance = uni.connect(impersonatedSigner4).approve(swapDexaddress, allowanceValue);
    console.log(`ALLOWANCE GRANTED ON ALL 3 TOKENS`);


    const daiBalance2 = await dai.connect(owner).balanceOf(impersonatedSigner.address);
    console.log(daiBalance2);

    ///////////////////////////////////////////
    // ADD LIQUIDITY
    /////////////////////////////////////////////
    console.log(`LIQUIDITY ADDING STARTED`);
    const daiLiquidity = await ethers.utils.parseEther("1");
    const addDaiLiquidity = await swapDex.connect(impersonatedSigner).addDaiLiquidity(daiLiquidity);
    console.log(`DAI COMPLETED`);
    const addUniLiquidity = await swapDex.connect(impersonatedSigner4).addUniLiquidity(daiLiquidity);
    console.log(`UNI COMPLETED`);
    const addUsdcLiquidity = await swapDex.connect(impersonatedSigner3).addUsdcLiquidity(100000000);
    console.log(`USDC COMPLETED`);
    console.log(`LIQUIDITY ADDED SUCCESFULLY`);

    ////////////////////////////////////////
    // CHECK CONTRACT BALANCE
    ////////////////////////////////////////
    console.log(`CONTRACT BALANCE CHECK STARTED`);
    const daiBalance = await dai.connect(impersonatedSigner).balanceOf(swapDexaddress);
    const UniBalance = await uni.connect(impersonatedSigner).balanceOf(swapDexaddress);
    const UsdcBalance = await usdc.connect(impersonatedSigner).balanceOf(swapDexaddress);

    console.log(`DAI BALANCE IS ${daiBalance}`);
    console.log(`UNI BALANCE IS ${UniBalance}`);
    console.log(`USDC BALANCE IS ${UsdcBalance}`);

    ////////////////////////////////////////////////
    // SWAP TOKENS <DAI TO USDC>
    ////////////////////////////////////////////////
    console.log(`DAI TO USDC SWAPPING STARTING`);
    const MyUsdcBalance = await usdc.connect(impersonatedSigner).balanceOf(impersonatedSigner.address);
    console.log(`USER USDC BALANCE B4 SWAP IS ${MyUsdcBalance}`);
    const swapDaiToUsdc = await swapDex.connect(impersonatedSigner).swapDaiToUsdc(1000);
    console.log(`token swapped sucessfully`);
    const UsdcBalanceOwner = await usdc.connect(impersonatedSigner).balanceOf(impersonatedSigner.address);
    console.log(`USER USDC BALANCE IS ${UsdcBalanceOwner}`);
    console.log(`DAI TO USDC SWAPPING COMPLETED`);


    //////////////////////////////
    //Swap USDC TO UNI
    ///////////////////////////
    console.log(`USDC TO UNI SWAPPING STARTED`);
    const UniBalanceOfOwnerB = await uni.connect(impersonatedSigner3).balanceOf(impersonatedSigner3.address);
    console.log(`USER Link BALANCE before swapping IS ${UniBalanceOfOwnerB}`);
    const swapUsdcToUni = await swapDex.connect(impersonatedSigner3).swapUsdcToUni(10000);
    console.log(`USDC to UNI swapped sucessfully`);
    const UniBalanceOfOwner = await uni.connect(impersonatedSigner3).balanceOf(impersonatedSigner3.address);
    console.log(`USER Link BALANCE IS ${UniBalanceOfOwner}`);
    console.log(`USDC TO UNI SWAPPING COMPLETED`);

    
    ///////////////////////////
    //SWAP UNI TO DAI
    ////////////////////////////
    console.log(`UNI TO DAI SWAPPING STARTED`);
    const DaiBalanceOfOwnerB = await dai.connect(impersonatedSigner4) .balanceOf(impersonatedSigner.address);
    console.log(`DAI BALANCE BEFORE SWAP IS ${DaiBalanceOfOwnerB}`);
    const swapUniToDai  = await swapDex.connect(impersonatedSigner4).swapUniToDai(50);

    const DaiBalanceOfOwnerA = await dai.connect(impersonatedSigner4) .balanceOf(impersonatedSigner.address);
    console.log(`DAI BALANCE AFTER SWAP IS ${DaiBalanceOfOwnerA}`);
    console.log(`UNI TO DAI SWAPPING COMPLETED`);

    /////////////////////////////////////
    // SWAP ETHER TO TOKEN LINK
    ///////////////////////////////////////



    const OldDaiBalanceOfOwner = await dai.connect(impersonatedSigner3).balanceOf(swapDex.address);
    console.log(`CONTRACT dai BALANCE BEFORE SWAP IS ${OldDaiBalanceOfOwner}`);

    const sent = await ethers.utils.parseEther("0.18");

    const swapEthToDai = await swapDex.connect(impersonatedSigner3).swapEthToDai(  {
        value: sent,
      })
    const NewDaiBalanceOfOwner = await dai.connect(impersonatedSigner3).balanceOf(impersonatedSigner3.address);
    console.log(`USER DAI BALANCE AFTER ETH2DAI SWAPP IS ${NewDaiBalanceOfOwner}`);
    
      
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });