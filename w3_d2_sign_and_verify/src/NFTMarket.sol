// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC2612} from "@openzeppelin/contracts/interfaces/IERC2612.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract NFTMarket is EIP712, Ownable {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("CheckWhiteList(address buyer,uint256 deadline)");

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    // 上架的NFT
    struct ListedNFT {
        address seller;
        address tokenAddr;
        uint256 price;
    }

    struct WhiteList {
        address buyer;
        uint256 deadline;
    }

    struct SignedData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    constructor() Ownable(msg.sender) EIP712("NFTMarket", "1") {}

    function sellerOf(
        address nftAddr,
        uint tokenId
    ) public view returns (address) {
        return listedNFTs[nftAddr][tokenId].seller;
    }

    function priceOf(address nftAddr, uint tokenId) public view returns (uint) {
        return listedNFTs[nftAddr][tokenId].price;
    }

    function list(
        address nftAddr,
        uint tokenId,
        address tokenAddr,
        uint price
    ) external {
        if (IERC721(nftAddr).ownerOf(tokenId) != msg.sender)
            revert IsNotTheOwner(IERC721(nftAddr).ownerOf(tokenId), msg.sender);
        listedNFTs[nftAddr][tokenId] = ListedNFT({
            seller: msg.sender,
            tokenAddr: tokenAddr,
            price: price
        });
        emit Listed(msg.sender, nftAddr, tokenId, tokenAddr, price);
    }

    function buyNFT(address nftAddr, uint256 tokenId) external {
        IERC721 nft = IERC721(nftAddr);
        //
        ListedNFT memory listedNFT = listedNFTs[nftAddr][tokenId];
        IERC20 token = IERC20(listedNFT.tokenAddr);
        // 判断该NFT是否上架或被卖出
        if (listedNFT.seller == address(0)) {
            revert IsSelledOrNotListed(nftAddr, tokenId);
        }
        //
        if (listedNFT.seller == msg.sender) {
            revert CannotBuyYouOwnNFT(nftAddr, tokenId, msg.sender);
        }
        // check whether the balance is enough
        if (token.balanceOf(msg.sender) < listedNFT.price)
            revert InsufficientBalance(msg.sender);
        token.transferFrom(msg.sender, listedNFT.seller, listedNFT.price);
        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
        delete listedNFTs[nftAddr][tokenId];
    }

    function hashStruct(
        WhiteList memory whiteList
    ) public view returns (bytes32) {
        return
            EIP712._hashTypedDataV4(
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        whiteList.buyer,
                        whiteList.deadline
                    )
                )
            );
    }

    function permitBuy(
        address nftAddr,
        uint256 tokenId,
        SignedData calldata nftData,
        SignedData calldata tokenData
    ) external {
        IERC721 nft = IERC721(nftAddr);
        // check whether the buyer is in white list
        checkWhiteList(msg.sender, nftData);
        //get the listed NFT info
        ListedNFT memory listedNFT = listedNFTs[nftAddr][tokenId];
        IERC20 token = IERC20(listedNFT.tokenAddr);
        // 判断该NFT是否上架或被卖出
        if (listedNFT.seller == address(0))
            revert IsSelledOrNotListed(nftAddr, tokenId);
        // buyer is the seller
        if (listedNFT.seller == msg.sender)
            revert CannotBuyYouOwnNFT(nftAddr, tokenId, msg.sender);
        // whether the buyer has engouth balance
        if (token.balanceOf(msg.sender) < listedNFT.price)
            revert InsufficientBalance(msg.sender);
        // get buyer permit
        IERC2612(listedNFT.tokenAddr).permit(
            msg.sender,
            address(this),
            listedNFT.price,
            tokenData.deadline,
            tokenData.v,
            tokenData.r,
            tokenData.s
        );
        //delete the listed NFT info
        delete listedNFTs[nftAddr][tokenId];
        // transfer from buyer to seller
        bool res = token.transferFrom(
            msg.sender,
            listedNFT.seller,
            listedNFT.price
        );
        if (!res)
            revert TransferFailed(
                msg.sender,
                listedNFT.seller,
                listedNFT.price
            );

        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
        emit NFTSellSuccess(listedNFT.seller, msg.sender, tokenId);
    }

    /**
     * check whether the buyer is in white list
     */
    function checkWhiteList(
        address buyer,
        SignedData calldata data
    ) private view {
        // check whether the signature is expired
        if (block.timestamp > data.deadline)
            revert ExpiredSignature(data.deadline);

        bytes32 digest = hashStruct(
            WhiteList({buyer: buyer, deadline: data.deadline})
        );
        address signer = ecrecover(digest, data.v, data.r, data.s);
        if (signer != owner()) revert InvalidSigner(signer, owner());
    }

    error IsNotTheOwner(address owner, address seller);

    error IsSelledOrNotListed(address nftAddr, uint tokenId);

    error CannotBuyYouOwnNFT(address nftAddr, uint tokenId, address seller);

    error TransferFailed(address from, address to, uint value);

    error ExpiredSignature(uint256 deadline);

    error InvalidSigner(address signer, address owner);

    error InsufficientBalance(address buyer);

    // Listed event
    event Listed(
        address indexed seller,
        address indexed nftAddr,
        uint indexed tokenId,
        address tokenAddr,
        uint price
    );

    // sell success event
    event NFTSellSuccess(
        address indexed seller,
        address indexed buyer,
        uint tokenId
    );
}
