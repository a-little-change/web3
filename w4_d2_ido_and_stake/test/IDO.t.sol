// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {IDO} from "../src/IDO.sol";

contract IDOTest is Test {
    IDO public ido;

    function setUp() public {
        ido = new IDO();
    }
}
