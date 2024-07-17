// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "./PetToken.sol";
import "./PetNFT.sol";

contract NFTMarket is EIP712 {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("CheckWhiteList(address buyer,uint256 deadline)");

    PetToken public tokenContract;

    address immutable owner;

    // NFT合约地址 => TokenId => 上架的NFT
    mapping(address => mapping(uint256 => ListedNFT)) listedNFTs;

    // 上架的NFT
    struct ListedNFT {
        address seller;
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
    }

    error IsSelledOrNotListed(address nftAddress, uint tokenId);

    error CannotBuyYouOwnNFT(address nftAddress, uint tokenId, address owner);

    error TransferFailed(address from, address to, uint value);

    error ExpiredSignature(uint256 deadline);

    error InvalidBuyer(address personInWhiteList, address buyer);

    // 上架事件
    event Listed(
        address indexed seller,
        address indexed nftAddress,
        uint indexed tokenId,
        uint price
    );

    // sell success event
    event NFTSellSuccess(
        address indexed seller,
        address indexed buyer,
        uint tokenId
    );

    constructor(address tokenAddress, address _owner) EIP712("NFT", "1") {
        tokenContract = PetToken(tokenAddress);
        owner = _owner;
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
        tokenContract.transferFrom(
            msg.sender,
            listedNFT.seller,
            listedNFT.price
        );
        nft.safeTransferFrom(listedNFT.seller, msg.sender, tokenId);
        delete listedNFTs[nftAddress][tokenId];
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
        address nftAddress,
        uint256 tokenId,
        uint256 deadline,
        uint256 deadline1,
        SignedData calldata nftData,
        SignedData calldata tokenData
    ) external {
        IERC721 nft = IERC721(nftAddress);
        // check whether the buyer is in white list
        checkWhiteList(msg.sender, deadline, nftData);

        ListedNFT memory listedNFT = listedNFTs[nftAddress][tokenId];
        // 判断该NFT是否上架或被卖出
        if (listedNFT.seller == address(0))
            revert IsSelledOrNotListed(nftAddress, tokenId);
        // buyer is the seller
        if (listedNFT.seller == msg.sender)
            revert CannotBuyYouOwnNFT(nftAddress, tokenId, msg.sender);

        // 判断余额是否充足
        require(
            tokenContract.balanceOf(msg.sender) >= listedNFT.price,
            "You balance isn't enough"
        );
        // get buyer permit
        tokenContract.permit(
            msg.sender,
            address(this),
            listedNFT.price,
            deadline1,
            tokenData.v,
            tokenData.r,
            tokenData.s
        );
        //delete the listed NFT info
        delete listedNFTs[nftAddress][tokenId];
        // transfer from buyer to owner
        bool res = tokenContract.transferFrom(msg.sender, owner, listedNFT.price);
        if (!res) revert TransferFailed(msg.sender, owner, listedNFT.price);

        nft.safeTransferFrom(owner, msg.sender, tokenId);
        emit NFTSellSuccess(owner, msg.sender, tokenId);
    }

    /**
     * check whether the buyer is in white list
     */
    function checkWhiteList(
        address buyer,
        uint deadline,
        SignedData calldata data
    ) private view {
        // check whether the signature is expired
        if (block.timestamp > deadline) revert ExpiredSignature(deadline);

        bytes32 digest = hashStruct(
            WhiteList({buyer: buyer, deadline: deadline})
        );
        address signer = ecrecover(digest, data.v, data.r, data.s);
        if (signer != owner) revert InvalidBuyer(signer, owner);
    }
}
