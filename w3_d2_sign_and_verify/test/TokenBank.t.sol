// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {PetToken} from "../src/PetToken.sol";
import {TokenBank} from "../src/TokenBank.sol";

contract TokenBankTest is Test {
    PetToken public petToken;
    TokenBank public tokenBank;

    event TokensReceived(address indexed from, uint256 value);

    function setUp() public {
        petToken = new PetToken();
        tokenBank = new TokenBank();
    }

    function test_PermitDeposit() public {
        Account memory alex = makeAccount("alex");
        deal(address(petToken), alex.addr, 1 ether);
        // create permit argument
        PetToken.Permit memory permit = PetToken.Permit({
            owner: alex.addr,
            spender: address(tokenBank),
            value: 1 ether,
            nonce: 0,
            deadline: 1 days
        });
        bytes32 digest = petToken.getTypedDataHash(permit);
        // sign by private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alex.key, digest);
        // expect event
        vm.expectEmit(true, false, false, true);
        emit TokensReceived(alex.addr, 1 ether);
        vm.prank(alex.addr);
        tokenBank.permitDeposit(address(petToken), 1 ether, 1 days, v, r, s);
    }
}
