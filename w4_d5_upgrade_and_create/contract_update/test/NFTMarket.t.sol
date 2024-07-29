// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract NFTMarketTest is Test {
    NFTMarketV1 market;
    address owner;
    address newOwner;
    address proxy;

    // Set up the test environment before running tests
    function setUp() public {
        // Define the owner address
        owner = vm.addr(1);
        // Deploy the proxy and initialize the contract through the proxy
        proxy = Upgrades.deployUUPSProxy(
            "NFTMarketV1.sol",
            abi.encodeCall(NFTMarketV1.initialize, owner)
        );
        market = NFTMarketV1(proxy);
        // Define a new owner address for upgrade tests
        newOwner = address(1);
        // Emit the owner address for debugging purposes
        emit log_address(owner);
    }

    // Test upgrade
    function testUpgradeability() public {
        // Upgrade the proxy to a new version; NFTMarketV2
        Upgrades.upgradeProxy(proxy, "NFTMarketV2.sol:NFTMarketV2", "", owner);
    }
}
