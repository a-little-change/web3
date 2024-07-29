// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";

contract NFTMarketV1Script is Script {
    NFTMarketV1 public nftMarket;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        nftMarket = new NFTMarketV1();
        vm.stopBroadcast();
        console.log("NFTMarketV1 Address:", address(nftMarket));
    }
}
