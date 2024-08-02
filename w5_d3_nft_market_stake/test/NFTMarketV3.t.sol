// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarketV3} from "../src/NFTMarketV3.sol";

contract NFTMarketV3Test is Test {
    NFTMarketV3 public market;

    function setUp() public {
        market = new NFTMarketV3();
        counter.setNumber(0);
    }

    function test_PermitBuyWithETH() {
        
    }
}
