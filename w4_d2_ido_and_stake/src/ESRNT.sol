// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ESRNT is ERC20, ERC20Permit {
    address public tokenAddr;

    mapping(address => LockInfo[]) public lockInfos;

    struct LockInfo {
        uint amount;
        uint lockTime;
    }

    constructor(
        address tokenAddr_
    ) ERC20("esRNTToken", "esRNT") ERC20Permit("esRNT") {
        tokenAddr = tokenAddr_;
    }

    function mint(address user, uint value) public {
        bool success = ERC20(tokenAddr).transferFrom(
            user,
            address(this),
            value
        );
        if (!success) revert TransferFailed(user, address(this), value);
        _mint(user, value);
        lockInfos[user].push(LockInfo(value, block.timestamp));
    }

    function burn(address user) public {
        uint benifit = 0;
        LockInfo[] memory infos = lockInfos[user];
        for (uint i = 0; i < infos.length; i++) {
            benifit += infos[i].amount * (block.timestamp - infos[i].lockTime);
        }

        _burn(user, balanceOf(user) - benifit);
    }

    error TransferFailed(address from, address to, uint value);
}
