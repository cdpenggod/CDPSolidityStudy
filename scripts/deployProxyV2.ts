import { ethers, network, upgrades } from "hardhat";
import { readAddressList, storeAddressList } from "./helper";

async function main() {
  console.log("Deploying to ", network.name);

  // 获取V1之前已部署的代理合约地址
  const addressListV2 = readAddressList();
  const proxyAddress = addressListV2['proxy'];
  // 更新合约，升级为V2
  const LogicV2 = await ethers.getContractFactory("LogicV2");
  const logicV2 = await upgrades.upgradeProxy(proxyAddress, LogicV2);

  // 获取相关地址
  // implementationV2获取的还是V1的，搞不清楚原因，但实际在链上已经更新成功了
  // const implementationV2 = await upgrades.erc1967.getImplementationAddress(logicV2.address);
  const adminV2 = await upgrades.erc1967.getAdminAddress(logicV2.address);

  console.log(logicV2.address," saharaV2 address(should be the same)")
  console.log(adminV2," AdminAddress");
  // console.log(implementationV2," ImplementationAddress")

  // 保存地址
  addressListV2['proxyV2'] = logicV2.address;
  addressListV2['adminV2'] = adminV2;
  // addressListV2['implementationV2'] = implementationV2;
  storeAddressList(addressListV2);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
