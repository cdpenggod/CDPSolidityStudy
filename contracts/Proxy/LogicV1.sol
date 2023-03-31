// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract LogicV1 is Initializable {
    uint256 version = 1;
    uint256 changeValue;
    // 数值改变通知
    event ValueHaveChange(uint256);

    function init(uint256 _changeValue) public initializer {
        changeValue = _changeValue;
    }

    function getChangeValue() public view returns (uint256) {
        return changeValue + 1;
    }

    function setChangeValue(uint256 newValue) public {
        changeValue = newValue;
        emit ValueHaveChange(newValue);
    }
}