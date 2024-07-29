// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";

contract NFTMarketV2Script is Script {
    NFTMarketV2 public nftMarket;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        nftMarket = new NFTMarketV2();
        vm.stopBroadcast();
        console.log("NFTMarketV2 Address:", address(nftMarket));
    }
}
