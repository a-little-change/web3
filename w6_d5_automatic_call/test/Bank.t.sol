// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;

    address public owner;

    function setUp() public {
        owner = makeAddr("owner");
        bank = new Bank(owner);
    }

    function test_Deposit() public {
        address depositor = makeAddr("dipositor");
        deal(depositor, 3 ether);
        // set expect event
        vm.expectEmit(true, true, false, true);
        emit TransferFrom(depositor, address(bank), 1 ether);
        // test deposit function
        vm.prank(depositor);
        bank.deposit{value: 1 ether}();
    }

    function test_Withdraw() public {
        deal(address(bank), 6 ether);

        vm.expectEmit(true, true, false, true);
        emit TransferFrom(address(bank), owner, 2 ether);

        vm.prank(owner);
        bank.withdraw(4 ether);
    }

    function test() public {
        // wrong address
        address myAddr1 = makeAddr(
            "0x7c19dF2f69d00b347B482B3dEd0C41A74a6Ffc16"
        ); // => 0x2525b8137249bC97aFfBAEb8C70337Ea916fC761
        console.logAddress(myAddr1);

        address myAddr2 = address(
            uint160(0x7c19dF2f69d00b347B482B3dEd0C41A74a6Ffc16)
        ); // => 0x2525b8137249bC97aFfBAEb8C70337Ea916fC761
        console.logAddress(myAddr2);

        address myAddr3 = vm.envAddress("MY_ADDR"); // => 0x2525b8137249bC97aFfBAEb8C70337Ea916fC761
        console.logAddress(myAddr3);
    }

    event TransferFrom(address indexed from, address indexed to, uint value);
}
