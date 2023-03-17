// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CDPPublish20 is ERC20 {
    address private owner;

    constructor() ERC20("CDP20 Token", "CDP20") {
        owner = msg.sender;
        _mint(msg.sender, 10000000 * 10**18);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "0 can't be owner");
        owner = newOwner;
    }

    function increase(uint256 amount) public onlyOwner {
        require(amount > 1, "amount need >0");
        _mint(msg.sender, amount * 10**18);
    }

    function reduce(uint256 amount) public onlyOwner {
        require(amount > 1, "amount need >0");
        _burn(msg.sender, amount * 10**18);
    }

    function pleaseGiveMeOne() public {
        require(msg.sender != owner, "You're kidding me!");
        _transfer(owner, msg.sender, 1  * 10**18);
    }

    function daddyGiveMe(uint256 amount) public {
        require(msg.sender != owner, "You're kidding me!");
        require(amount > 0 && amount <= 100, "need 0<amount<=100");
        _transfer(owner, msg.sender, amount * 10**18);
    }
}