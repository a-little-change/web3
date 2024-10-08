// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract NFTMarketScript is Script {
    NFTMarket public market;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        market = new NFTMarket();
        vm.stopBroadcast();
        console.log("NFTMarket's address:", address(market));
    }
}
