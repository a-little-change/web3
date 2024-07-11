// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "src/NFTMarket.sol";
import {Pet} from "src/Pet.sol";
import {PetNFT} from "../src/PetNFT.sol";

contract NFTMarketTest is Test {
    Pet pet;
    PetNFT petNFT;
    NFTMarket nftMarket;

    // 上架事件
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint indexed tokenId,
        uint price
    );

    error IsSelledOrNotListed(address nftAddress, uint tokenId);
    error CannotBuyYouOwnNFT(address nftAddress, uint tokenId, address owner);
    function setUp() public {
        pet = new Pet();
        petNFT = new PetNFT();
        nftMarket = new NFTMarket(address(pet));
    }
    function test_List() public {
        // 铸造NFT
        address alex = makeAddr("alex");
        petNFT.mint(alex, 1);
        uint price = 1 ether;
        vm.prank(alex);
        // 预期上架事件
        vm.expectEmit(true, true, true, true);
        emit Listed(alex, address(petNFT), 1, price);
        // 上架
        nftMarket.list(address(petNFT), 1, price);
        // 断言上架信息
        assertEq(alex, nftMarket.sellerOf(address(petNFT), 1));
        assertEq(price, nftMarket.priceOf(address(petNFT), 1));
    }

    function test_BuyNFT() public {
        address alex = makeAddr("alex");
        petNFT.mint(alex, 1);
        uint price = 1 ether;
        // nft授权
        vm.prank(alex);
        petNFT.approve(address(nftMarket), 1);
        // 上架
        vm.prank(alex);
        nftMarket.list(address(petNFT), 1, price);

        address bob = makeAddr("bob");
        deal(address(pet), bob, 1 ether);
        // token授权
        vm.prank(bob);
        pet.approve(address(nftMarket), 1 ether);
        // 购买NFT
        vm.prank(bob);
        nftMarket.buyNFT(address(petNFT), 1);
        //断言NFT是否购买成功
        assertEq(petNFT.ownerOf(1), bob);
    }

    function testFailed_BuyNFT() public {
        address alex = makeAddr("alex");
        petNFT.mint(alex, 1);
        uint price = 1 ether;
        // nft授权
        vm.prank(alex);
        petNFT.approve(address(nftMarket), 1);
        // 上架
        vm.prank(alex);
        nftMarket.list(address(petNFT), 1, price);

        deal(address(pet), alex, 1 ether);
        // token授权
        vm.prank(alex);
        pet.approve(address(nftMarket), 1 ether);
        // 购买NFT
        vm.prank(alex);
        vm.expectRevert(
            abi.encodeWithSelector(
                CannotBuyYouOwnNFT.selector,
                address(petNFT),
                1,
                alex
            )
        );
        nftMarket.buyNFT(address(petNFT), 1);
    }

    function testFailed1_BuyNFT() public {
        address alex = makeAddr("alex");
        petNFT.mint(alex, 1);
        uint price = 1 ether;
        // nft授权
        vm.prank(alex);
        petNFT.approve(address(nftMarket), 1);
        // 上架
        vm.prank(alex);
        nftMarket.list(address(petNFT), 1, price);

        address bob = makeAddr("bob");
        vm.prank(bob);
        deal(address(pet), bob, 1 ether);
        // token授权
        vm.prank(bob);
        pet.approve(address(nftMarket), 1 ether);
        // NFT被购买
        vm.prank(bob);
        nftMarket.buyNFT(address(petNFT), 1);

        address alice = makeAddr("alice");
        deal(address(pet), alice, 1 ether);
        // token授权
        vm.prank(alice);
        pet.approve(address(nftMarket), 1 ether);
        // 购买NFT
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                IsSelledOrNotListed.selector,
                address(petNFT),
                1
            )
        );
        nftMarket.buyNFT(address(petNFT), 1);
    }

    function testFuzz_BuyNFT(uint price, address buyer) public {
        // 铸造NFT
        address alex = makeAddr("alex");
        petNFT.mint(alex, 1);
        vm.assume(price > 0.01 ether && price < 10000 ether);
        vm.assume(buyer != address(0));
        // nft授权
        vm.prank(alex);
        petNFT.approve(address(nftMarket), 1);
        // 上架
        vm.prank(alex);
        nftMarket.list(address(petNFT), 1, price);

        deal(address(pet), buyer, price);
        // token授权
        vm.prank(buyer);
        pet.approve(address(nftMarket), price);
        // 购买NFT
        vm.prank(buyer);
        nftMarket.buyNFT(address(petNFT), 1);
        //断言NFT是否购买成功
        assertEq(petNFT.ownerOf(1), buyer);
    }
}
