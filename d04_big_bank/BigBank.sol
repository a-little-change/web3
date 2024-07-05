// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "d04_big_bank/Bank.sol";

contract BigBank is Bank {
    error AmountTooLess();

    error IsNotOwner();

    constructor() {
        owner = msg.sender;
    }

    // 检验存款金额
    modifier checkAmount() {
        if (msg.value < 1000000000000000) {
            revert AmountTooLess();
        }
        _;
    }

    // 存款
    receive() external payable override checkAmount {
        // 将存款余额放入映射
        balances[msg.sender] += msg.value;
        // 重排存款金额的前3名用户
        rankAmount(msg.sender, balances[msg.sender]);
    }

    // 转移BigBank的管理员
    function transferOwner(address newOwner) external {
        if (msg.sender != owner) {
            revert IsNotOwner();
        }
        owner = newOwner;
    }
}
