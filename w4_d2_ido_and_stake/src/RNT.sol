// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNT is ERC20, Ownable {
    constructor(
        address owner_,
        uint totalSupply_
    ) ERC20("RNTToken", "RNT") Ownable(owner_) {
        // mint the tokens to owner
        _mint(owner_, totalSupply_);
    }
}
