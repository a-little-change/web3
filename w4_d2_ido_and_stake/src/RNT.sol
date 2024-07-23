// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNT is ERC20, ERC20Permit {
    uint256 public initalSupply = 1e9 ether;

    constructor() ERC20("RNTToken", "RNT") ERC20Permit("RNT") {
        // mint
        _mint(msg.sender, initalSupply);
    }
}
