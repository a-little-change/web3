// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is Ownable, ERC20 {
    uint public immutable initalSupply;

    uint public immutable perMint;

    constructor(
        string memory name_,
        string memory symbol_,
        uint initalSupply_,
        uint perMint_,
        address owner_
    ) ERC20(name_, symbol_) Ownable(owner_) {
        initalSupply = initalSupply_;
        perMint = perMint_;
    }

    function mint(address user) external {
        require(owner() == msg.sender,"Not the Owner");
        if ((totalSupply() + perMint) > initalSupply) revert();
        _mint(user, perMint);
    }
}
