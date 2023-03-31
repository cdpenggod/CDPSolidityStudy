import { ethers, network } from "hardhat";
import { storeCDP20TokenAddress } from "./helper";

async function main() {
  const Token = await ethers.getContractFactory("CDPPublish20");
  const token = await Token.deploy();

  // 等待部署完成
  await token.deployed();

  storeCDP20TokenAddress(network.name, token.address);

  console.log("Deployed CDP20 on", network.name, "by", token.deployTransaction.from);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
