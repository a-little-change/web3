// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {PetToken} from "../src/PetToken.sol";
import {PetNFT} from "../src/PetNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract NFTMarketTest is Test {
    PetToken public petToken;
    PetNFT public petNFT;
    NFTMarket public nftMarket;
    Account public owner;

    // sell success event
    event NFTSellSuccess(
        address indexed seller,
        address indexed buyer,
        uint tokenId
    );

    function setUp() public {
        owner = makeAccount("owner");
        petToken = new PetToken();
        petNFT = new PetNFT();
        nftMarket = new NFTMarket(address(petToken), owner.addr);
    }

    function test_PermitBuy() public {
        petNFT.mint(owner.addr, 1);
        uint price = 1 ether;
        // listed
        vm.prank(owner.addr);
        nftMarket.list(address(petNFT), 1, price);
        // approve nft to nft market
        vm.prank(owner.addr);
        petNFT.approve(address(nftMarket), 1);
        // create the buyer's account
        Account memory alex = makeAccount("alex");
        deal(address(petToken), alex.addr, price);
        // owner sign then add in whitelist
        bytes32 digest = nftMarket.hashStruct(
            NFTMarket.WhiteList({buyer: alex.addr, deadline: 7 days})
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner.key, digest);
        NFTMarket.SignedData memory nftData = NFTMarket.SignedData({
            v: v,
            r: r,
            s: s
        });
        // second sign permit
        bytes32 digest1 = petToken.getTypedDataHash(
            PetToken.Permit({
                owner: alex.addr,
                spender: address(nftMarket),
                value: price,
                nonce: 0,
                deadline: 1 days
            })
        );
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(alex.key, digest1);
        NFTMarket.SignedData memory tokenData = NFTMarket.SignedData({
            v: v1,
            r: r1,
            s: s1
        });
        // except event
        vm.expectEmit(true, true, false, true);
        emit NFTSellSuccess(owner.addr, alex.addr, 1);
        vm.prank(alex.addr);
        nftMarket.permitBuy(
            address(petNFT),
            1,
            7 days,
            1 days,
            nftData,
            tokenData
        );
    }
}
