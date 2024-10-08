// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenScript is Script {
    MyToken public myToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        myToken = new MyToken("PetToken", "Pet");
        vm.stopBroadcast();
        console.log("Pet token address: ", address(myToken));
    }
}
