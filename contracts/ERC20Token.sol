// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
        Ownable(msg.sender)  // Launchpad will be the owner
    {
        _mint(msg.sender, initialSupply * 10 ** decimals());
        // Removed incorrect approval line
    }

    // Optional: Add a utility function to easily approve the launchpad
    function approveForLaunchpad(uint256 amount) public returns (bool) {
        address launchpad = owner(); // The owner is the launchpad that deployed this token
        return approve(launchpad, amount);
    }
}