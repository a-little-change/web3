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
        petToken = new PetToken();
        petNFT = new PetNFT();
        owner = makeAccount("owner");
        vm.prank(owner.addr);
        nftMarket = new NFTMarket();
    }

    function test_PermitBuy() public {
        Account memory seller = makeAccount("seller");
        petNFT.mint(seller.addr, 1);
        uint price = 1 ether;
        // listed
        vm.prank(seller.addr);
        nftMarket.list(address(petNFT), 1, address(petToken), price);
        // approve nft to nft market
        vm.prank(seller.addr);
        petNFT.approve(address(nftMarket), 1);
        // create the buyer's account
        Account memory alex = makeAccount("alex");
        deal(address(petToken), alex.addr, price);
        // seller sign then add in whitelist
        bytes32 digest = nftMarket.hashStruct(
            NFTMarket.WhiteList({buyer: alex.addr, deadline: 7 days})
        );
        // nft market owner sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(owner.key, digest);
        NFTMarket.SignedData memory nftData = NFTMarket.SignedData({
            deadline: 7 days,
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
            deadline: 1 days,
            v: v1,
            r: r1,
            s: s1
        });
        // except event
        vm.expectEmit(true, true, false, true);
        emit NFTSellSuccess(seller.addr, alex.addr, 1);
        vm.prank(alex.addr);
        nftMarket.permitBuy(address(petNFT), 1, nftData, tokenData);
    }
}
