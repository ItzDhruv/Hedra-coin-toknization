// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address creator)
        ERC20(name, symbol)
       
    {
        _mint(creator, initialSupply * 10 ** decimals());

        // Approve TokenLaunchpad (msg.sender) to transfer tokens on behalf of creator
        _approve(creator, msg.sender, initialSupply * 10 ** decimals());
    }
}
