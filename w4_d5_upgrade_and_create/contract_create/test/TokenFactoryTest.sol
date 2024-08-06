// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {PetTokenV2} from "../src/PetTokenV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract PetTokenTest is Test {
    PetTokenV2 token;
    ERC1967Proxy proxy;
    address owner;
    address newOwner;

    // Set up the test environment before running tests
      function setUp() public {
        // Deploy implement
        PetTokenV2 implementation = new PetTokenV2();
        // Define the owner address
        owner = vm.addr(1);
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(address(implementation), abi.encodeCall(implementation.initialize, owner));
        // 
        token = PetTokenV2(address(proxy));
        // Define a new owner address for upgrade tests
        newOwner = address(1);
        // Emit the owner address for debugging purposes
        emit log_address(owner);
    }

    // Test the basic ERC20 functionality of the MyToken contract
    function testERC20Functionality() public {
        // Impersonate the owner to call mint function
        vm.prank(owner);
        // Mint tokens to address(2) and assert the balance
        token.mint(address(2), 1000);
        assertEq(token.balanceOf(address(2)), 1000);
    }

    // Test upgrade
    function testUpgradeability() public {
        // Upgrade the proxy to a new version; PetTokenV2
        Upgrades.upgradeProxy(address(proxy), "PetTokenV2.sol:PetTokenV2", "", owner);
    }
}