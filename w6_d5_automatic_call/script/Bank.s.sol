// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Bank} from "../src/Bank.sol";

contract BankScript is Script {
    Bank public bank;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // set my address as owner
        address myAddr = vm.envAddress("MY_ADDR");
        bank = new Bank(myAddr);

        vm.stopBroadcast();
    }
}
