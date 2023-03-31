// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract LogicV2 is Initializable {
    uint256 constant version = 2;
    uint256 changeValue;
    // 数值改变通知
    event ValueHaveChange(uint256);
    // 执行了SayHi
    event DoSayHi();
    mapping (address => uint) changeValueForUser;

    function init(uint256 _changeValue) public initializer {
        changeValue = _changeValue;
    }

    function getChangeValue() public view returns (uint256) {
        return changeValueForUser[msg.sender];
    }

    function setChangeValue(uint256 newValue) public {
        require(newValue > 0, "changeValue need > 0");
        changeValue = newValue;
        changeValueForUser[msg.sender]= newValue;
        emit ValueHaveChange(newValue);
    }

    function sayHi() public returns (string memory) {
        emit DoSayHi();
        return "Hi, baby~";
    }

    function isUserChangeValue() public view returns (bool) {
        return (changeValueForUser[msg.sender] > 0);
    }
}