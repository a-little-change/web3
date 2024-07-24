// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {esRNT} from "../src/esRNT.sol";

contract esRNTScript is Script {
    esRNT public esrnt;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        esrnt = new esRNT();
        vm.stopBroadcast();
        console.log("esRNT contract address:", address(esrnt));
    }
}
