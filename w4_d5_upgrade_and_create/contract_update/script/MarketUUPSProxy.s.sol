// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract MarketUUPSProxyScript is Script {
    function run() public {
        vm.startBroadcast();

        // Deploy the proxy contract with the implementation address and initializer
        address proxy = Upgrades.deployUUPSProxy(
            "NFTMarketV1.sol",
            abi.encodeCall(NFTMarketV1.initialize, msg.sender)
        );
        vm.stopBroadcast();
        // Log the proxy address
        console.log("NFT Market UUPS Proxy Address:", proxy);
    }
}
