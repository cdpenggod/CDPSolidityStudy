import { ethers, network, upgrades } from "hardhat";
import { readAddressList, storeAddressList } from "./helper";

async function main() {
  console.log("Deploying to ", network.name);

  const Logic = await ethers.getContractFactory("LogicV1");
  const logic = await upgrades.deployProxy(Logic, [1], {initializer: 'init'})
  // 开始部署
  await logic.deployed();

  // 获取相关地址
  const admin = await upgrades.erc1967.getAdminAddress(logic.address);
  const implementation = await upgrades.erc1967.getImplementationAddress(logic.address);

  console.log(logic.address," ------ proxy address")
  console.log(admin," ------ AdminAddress");
  console.log(implementation," ------ logic address")

  // 保存地址
  const addressList = readAddressList();
  addressList['proxy'] = logic.address;
  addressList['admin'] = admin;
  addressList['implementation'] = implementation;
  storeAddressList(addressList);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
