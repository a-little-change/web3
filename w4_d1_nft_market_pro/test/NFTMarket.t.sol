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

    // sell success event
    event NFTSellSuccess(
        address indexed nft,
        uint indexed tokenId,
        address indexed seller,
        address buyer
    );

    function setUp() public {
        petToken = new PetToken();
        petNFT = new PetNFT();
        nftMarket = new NFTMarket();
    }

    function test_PermitBuy() public {
        Account memory seller = makeAccount("seller");
        petNFT.mint(seller.addr, 1);
        uint price = 1 ether;
        // approve nft to nft market
        vm.prank(seller.addr);
        petNFT.setApprovalForAll(address(nftMarket), true);
        // create the buyer's account
        Account memory alex = makeAccount("alex");
        deal(address(petToken), alex.addr, price);
        NFTMarket.LimitOrder memory order = NFTMarket.LimitOrder({
            maker: seller.addr,
            nft: address(petNFT),
            tokenId: 1,
            payToken: address(petToken),
            price: price,
            deadline: 7 days
        });
        // seller sign add in whitelist
        bytes32 digest = nftMarket.hashStruct(order);
        // seller sign to confirm the order
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(seller.key, digest);
        NFTMarket.SignedData memory signedOrder = NFTMarket.SignedData({
            v: v,
            r: r,
            s: s
        });
        // buyer sign permit
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
        NFTMarket.SignedData memory signedToken = NFTMarket.SignedData({
            v: v1,
            r: r1,
            s: s1
        });
        // except event
        vm.expectEmit(true, true, true, true);
        emit NFTSellSuccess(address(petNFT), 1, seller.addr, alex.addr);
        vm.prank(alex.addr);
        nftMarket.permitBuy(order, signedOrder, 1 days, signedToken);
    }

    function test_PermitBuyByETH() public {
        Account memory seller = makeAccount("seller");
        petNFT.mint(seller.addr, 1);
        // approve nft to nft market
        vm.prank(seller.addr);
        petNFT.setApprovalForAll(address(nftMarket), true);
        // create the buyer's account
        Account memory alex = makeAccount("alex");
        deal(alex.addr, 1.1 ether);
        console.log("eth balace:", alex.addr.balance);
        NFTMarket.LimitOrder memory order = NFTMarket.LimitOrder({
            maker: seller.addr,
            nft: address(petNFT),
            tokenId: 1,
            payToken: address(0),
            price: 1 ether,
            deadline: 7 days
        });
        // seller sign add in whitelist
        bytes32 digest = nftMarket.hashStruct(order);
        // seller sign to confirm the order
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(seller.key, digest);
        NFTMarket.SignedData memory signedOrder = NFTMarket.SignedData({
            v: v,
            r: r,
            s: s
        });
        // except event
        vm.expectEmit(true, true, true, true);
        emit NFTSellSuccess(address(petNFT), 1, seller.addr, alex.addr);
        vm.prank(alex.addr);
        nftMarket.permitBuyByETH{value: 1 ether}(order, signedOrder);
        console.log("eth balace:", alex.addr.balance);
    }
}
