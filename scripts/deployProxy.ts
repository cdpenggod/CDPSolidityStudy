import { DeployFunction, ProxyOptions } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { readAddressList, storeAddressList } from "./helper";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying My Contract with account:", deployer);

  const addressList = readAddressList();

  const proxyOptions: ProxyOptions = {
    proxyContract: "TransparentUpgradeableProxy",
    viaAdminContract: "ProxyAdmin",
    execute: {
      // 只在初始化时执行
      init: {
        // 执行initialize方法
        methodName: "init",
        // 参数
        args: [1],
      },
    },
  };

  const logicContract = await deploy("LogicV1", {
    contract: "LogicV1",
    from: deployer,
    proxy: proxyOptions,
    args: [],
    log: true,
  });

  console.log("Proxy deployed to:", logicContract.address);
  console.log("Implementation deployed to:", logicContract.implementation);

  addressList[network.name].LogicContract = logicContract.address;
  storeAddressList(addressList);
};

// npx hardhat deploy --network {network} --tags {Tag}
func.tags = ["MyContract"];
export default func;
