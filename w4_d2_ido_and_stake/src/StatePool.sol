// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC2612} from "@openzeppelin/contracts/interfaces/IERC2612.sol";
import {ESRNT} from "./ESRNT.sol";

contract StakePool {
    mapping(address => StakeInfo) stakeInfos;

    struct StakeInfo {
        uint staked;
        uint unclaimed;
        uint lastUpdateTime;
    }

    address public token;

    address public esToken;

    constructor(address token_, address esToken_) {
        token = token_;
        esToken = esToken_;
    }

    function stake(uint value) public {
        IERC20(token).transferFrom(msg.sender, address(this), value);
        StakeInfo memory info = stakeInfos[msg.sender];
        info.unclaimed += info.staked * (block.timestamp - info.lastUpdateTime);
        info.staked += value;
        info.lastUpdateTime = block.timestamp;
    }

    function unstake(uint value) public {
        IERC20(token).transfer(msg.sender, value);
        StakeInfo memory info = stakeInfos[msg.sender];
        info.unclaimed += info.staked * (block.timestamp - info.lastUpdateTime);
        info.staked -= value;
        info.lastUpdateTime = block.timestamp;
    }

    function claim() public {
        StakeInfo memory info = stakeInfos[msg.sender];
        info.unclaimed += info.staked * (block.timestamp - info.lastUpdateTime);
        info.lastUpdateTime = block.timestamp;
        ESRNT(token).mint(msg.sender, info.unclaimed);
        info.unclaimed = 0;
    }
}
