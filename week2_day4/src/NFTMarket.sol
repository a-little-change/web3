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

    IERC20 public tokenContract;

    error IsSelledOrNotListed(address nftAddress, uint tokenId);

    error CannotBuyYouOwnNFT(address nftAddress, uint tokenId, address owner);

    error TransferFailed(address from, address to, uint value);

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    // 上架事件
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint indexed tokenId,
        uint price
    );
    constructor(address tokenAddress) {
        tokenContract = IERC20(tokenAddress);
    }

    function sellerOf(
        address nftAddress,
        uint tokenId
    ) public view returns (address) {
        return listedNFTs[nftAddress][tokenId].seller;
    }
    function priceOf(
        address nftAddress,
        uint tokenId
    ) public view returns (uint) {
        return listedNFTs[nftAddress][tokenId].price;
    }

    function list(address nftAddress, uint256 tokenId, uint256 price) external {
        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == msg.sender, "You are not the Owner!");
        listedNFTs[nftAddress][tokenId] = ListedNFT({
            seller: msg.sender,
            price: price
        });
        emit Listed(msg.sender, nftAddress, tokenId, price);
    }

    function buyNFT(address nftAddress, uint256 tokenId) external {
        IERC721 nft = IERC721(nftAddress);
        ListedNFT memory listedNFT = listedNFTs[nftAddress][tokenId];
        
        // 判断该NFT是否上架或被卖出
        if (listedNFT.seller == address(0)) {
            revert IsSelledOrNotListed(nftAddress, tokenId);
        }
        // 
        if (listedNFT.seller == msg.sender) {
            revert CannotBuyYouOwnNFT(nftAddress, tokenId, msg.sender);
        }
        // 判断余额是否充足
        require(
            tokenContract.balanceOf(msg.sender) >= listedNFT.price,
            "You balance isn't enough"
        );
          delete listedNFTs[nftAddress][tokenId];
        bool success = tokenContract.transferFrom(
            msg.sender,
            listedNFT.seller,
            listedNFT.price
        );
        if(!success) revert TransferFailed(msg.sender, listedNFT.seller, listedNFT.price);
        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
    }
}
