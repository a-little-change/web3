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

    /**
     * Calculate the previous interest
     */
    function _calInterest() private {
        if (stakeInfos[msg.sender].staked != 0)
            stakeInfos[msg.sender].unclaimed +=
                stakeInfos[msg.sender].staked *
                (block.timestamp - stakeInfos[msg.sender].lastUpdateTime);
        stakeInfos[msg.sender].lastUpdateTime = block.timestamp;
    }

    function stake(uint value) public {
        _calInterest();
        stakeInfos[msg.sender].staked += value;
        // transfer staked tokens to this contract
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            value
        );
        if (!success) revert TransferFailed(msg.sender, address(this), value);
    }

    function unstake(uint value) public {
        _calInterest();
        stakeInfos[msg.sender].staked -= value;
        // transfer unstaked tokens to user
        bool success = IERC20(token).transfer(msg.sender, value);
        if (!success) revert TransferFailed(address(this), msg.sender, value);
    }

    function claim() public {
        _calInterest();
        // set unclaimed esRNT to 0, prevent reentrant attacks
        uint interest = stakeInfos[msg.sender].unclaimed;
        stakeInfos[msg.sender].unclaimed = 0;
        ESRNT(token).mint(msg.sender, interest);
    }

    error TransferFailed(address from, address to, uint value);
}
