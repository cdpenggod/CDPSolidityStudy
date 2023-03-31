import * as fs from "fs";

export const readAddressList = function () {
  return JSON.parse(fs.readFileSync("address.json", "utf-8"));
};

export const storeAddressList = function (addressList: object) {
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};

export const getCDP20TokenAddress = function (network: string) {
  const addressList = readAddressList();
  return addressList[network].CDP20;
};

export const storeCDP20TokenAddress = function (network: string, address: string) {
  const addressList = readAddressList();
  addressList[network].CDP20 = address;
  storeAddressList(addressList);
};