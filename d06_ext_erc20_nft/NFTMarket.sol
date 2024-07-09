// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarket {
    // 上架的NFT
    struct ListedNFT {
        address seller;
        uint256 price;
    }

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    IERC20 public payment;

    constructor(address _payment) {
        payment = IERC20(_payment);
    }

    function list(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "You are not the Owner!");

        listedNFTs[nftContract][tokenId] = ListedNFT({
            seller: msg.sender,
            price: price
        });
    }

    function buyNFT(address nftContract, uint256 tokenId) external {
        IERC721 nft = IERC721(nftContract);
        ListedNFT memory listedNFT = listedNFTs[nftContract][tokenId];
        // 判断该NFT是否上架
        require(listedNFT.seller != address(0), "This nft isn't for sale");
        // 判断余额是否充足
        require(
            payment.balanceOf(msg.sender) >= listedNFT.price,
            "You balance isn't enough"
        );
        payment.transferFrom(msg.sender, listedNFT.seller, listedNFT.price);
        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
        delete listedNFTs[nftContract][tokenId];
    }
}
