// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MultisigWallet} from "../src/MultisigWallet.sol";

contract MultisigWalletTest is Test {
    MultisigWallet public multisigWallet;
    address[] public owners;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address mark = makeAddr("mark");

    event Deposit(address indexed sender, uint amount, uint balance);

    function setUp() public {
        owners.push(alice);
        owners.push(bob);
        owners.push(mark);
        multisigWallet = new MultisigWallet(owners, 2);
    }

    function test_ExecuteTransaction() public {
        vm.prank(mark);
        vm.expectRevert("Not enough signer");
        multisigWallet.executeTransaction(mark, 1 ether, "");
        console.log("alice: ", alice.balance);
        deal(alice, 2 ether);
        // alice deposit
        vm.prank(alice);
        (bool success, ) = address(multisigWallet).call{value: 1 ether}("");
        if (!success) revert();
        // vm.expectEmit(true, false, false, true);
        // emit Deposit(alice, 1 ether, address(multisigWallet).balance);
        // alice sign
        vm.prank(alice);
        multisigWallet.confrim();
        // bob sign
        vm.prank(bob);
        multisigWallet.confrim();
        uint balance = mark.balance;
        console.log("mark: ", balance);
        //mark withdraw
        vm.prank(mark);
        multisigWallet.executeTransaction(mark, 1 ether, "");
        assertEq(mark.balance, (balance + 1 ether));
    }
}
