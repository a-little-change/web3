// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MyWallet} from "../src/MyWallet.sol";

contract MyWalletTest is Test {
    MyWallet public wallet;
    address public owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        wallet = new MyWallet("Wallet");
    }

    function test_TransferOwernship() public {
        address alex = makeAddr("alex");
        console.log(alex);
        vm.prank(owner);
        wallet.transferOwernship(alex);
        console.log(wallet.owner());

        console.logBytes32(keccak256("0"));
        console.logBytes32(keccak256("0x0000000000000000000000000000000000000000000000000000000000000000"));
        console.logBytes32(keccak256("0x0"));
    }
}
