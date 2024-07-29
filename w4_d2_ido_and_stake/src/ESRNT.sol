// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ESRNT is ERC20 {
    address public immutable tokenAddr;

    address public immutable stakeAddr;

    mapping(address => LockInfo[]) public lockInfos;

    struct LockInfo {
        uint amount;
        uint lockTime;
    }

    constructor(
        address tokenAddr_,
        address stakeAddr_
    ) ERC20("esRNTToken", "esRNT") {
        tokenAddr = tokenAddr_;
        stakeAddr = stakeAddr_;
    }

    function mint(address user, uint value) external {
        // Only stake contract can mint esRNT
        if (msg.sender != stakeAddr) revert IsNotOwner(msg.sender);
        //
        address tokenOwner = Ownable(tokenAddr).owner();
        // transfer RNT from RNT owner to this contract
        bool success = ERC20(tokenAddr).transferFrom(
            tokenOwner,
            address(this),
            value
        );
        if (!success) revert TransferFailed(tokenOwner, address(this), value);
        // mint esRNT to user
        _mint(user, value);
        lockInfos[user].push(LockInfo(value, block.timestamp));
    }

    function convertAll() public {
        if (balanceOf(msg.sender) == 0)
            revert InsufficientBalance(msg.sender, balanceOf(msg.sender));
        //
        uint benifit = 0;
        for (uint i = 0; i < lockInfos[msg.sender].length; i++) {
            benifit +=
                lockInfos[msg.sender][i].amount *
                (block.timestamp - lockInfos[msg.sender][i].lockTime);
        }
        // delete used lockInfos
        delete lockInfos[msg.sender];
        _burn(msg.sender, balanceOf(msg.sender) - benifit);
        bool success = ERC20(tokenAddr).transferFrom(
            address(this),
            msg.sender,
            benifit
        );
        if (!success) revert TransferFailed(address(this), msg.sender, benifit);
    }

    error IsNotOwner(address sender);

    error TransferFailed(address from, address to, uint value);

    error InsufficientBalance(address sender, uint balance);
}
