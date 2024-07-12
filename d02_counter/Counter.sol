// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    // 定义状态变量 counter
    int256 counter;

    // 获取 counter 的值
    function get() public view returns (int256) {
        return counter;
    }

    // 给变量加上 x
    function add(int256 x) public {
        counter += x;
    }
}
