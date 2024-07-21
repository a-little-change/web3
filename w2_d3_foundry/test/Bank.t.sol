// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";
contract BankTest is Test {
    Bank public bank;

    event Deposit(address indexed user, uint amount);
    function setUp() public {
        bank = new Bank();
    }

    function test_DepositETH() public {
        uint amount = 1;

        // 预期事件
        vm.expectEmit(true, true, false, true);
        emit Deposit(address(this), amount);
        console.log(address(this).balance);
        bank.depositETH{value: amount}();

        assertEq(bank.balanceOf(address(this)), amount);
    }

    function testBuzz_DepositETH(uint x) public {
        vm.assume(x > 0 && x < 1e9 ether);
        deal(address(this), 1e9 ether);
       
        // 预期事件
        vm.expectEmit(true, true, false, true);
        emit Deposit(address(this), x);
        
         bank.depositETH{value: x}();

        assertEq(bank.balanceOf(address(this)), x);
    }
}